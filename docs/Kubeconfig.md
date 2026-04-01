# Kubeconfig

## Problema

Como este proyecto destruye y recrea la VM seguido para no gastar de más, no conviene depender de la IP pública de AWS.

Además, el kubeconfig que genera `k3s` viene con:

`server: https://127.0.0.1:6443`

Eso solo sirve dentro de la VM.

## Solución

Usar Tailscale para llegar al server por red privada y configurar `k3s` con `--tls-san athenea`.

Con eso, el kubeconfig se puede bajar a la máquina local y cambiar su `server` a:

`https://athenea:6443`

De esa forma:

- no hace falta depender de la IP pública cambiante del server
- no hace falta abrir `6443` públicamente
- el acceso administrativo viaja por la red privada de Tailscale

Nota:

El kubeconfig deja de depender de la IP pública de AWS y pasa a depender del nombre `athenea` dentro de Tailscale.

Si la VM se destruye y recrea, puede cambiar también la IP privada de Tailscale. Por eso conviene depender del nombre `athenea` y no de una IP de Tailscale fija.

Si la VM se destruye y recrea, sigue haciendo falta volver a bajar el kubeconfig del cluster nuevo.

Lo que ya no hace falta es andar persiguiendo IPs de AWS.

## Por Qué Hace Falta El YAML

El archivo `/etc/rancher/k3s/k3s.yaml` es el kubeconfig del cluster.

En `k3s`, esta es la manera normal de obtener el kubeconfig del cluster: leer o copiar `/etc/rancher/k3s/k3s.yaml` desde el server.

Ese YAML contiene:

- la dirección del API server
- el certificado de la CA
- las credenciales de cliente
- el contexto por defecto

`kubectl`, `kubectx` y `kubens` necesitan ese archivo para saber a qué cluster conectarse y con qué credenciales.

Sin ese YAML, `kubectl` local no sabe cómo hablar con el cluster.

Aunque el cluster use `athenea` por Tailscale, igual hace falta ese YAML porque ahí viven los certificados, credenciales y contexto.

## Flujo

1. Copiar `/etc/rancher/k3s/k3s.yaml` a la máquina local.
2. Reemplazar `https://127.0.0.1:6443` por `https://athenea:6443`.
3. Guardarlo como `~/.kube/athenea.yaml`.
4. Exportar `KUBECONFIG="$HOME/.kube/athenea.yaml"`.
5. Usar `kubectl`, `kubectx` y `kubens` normalmente.

## Script

El flujo de arriba se automatiza con un script local que:

1. se conecta por Tailscale a `athenea`
2. baja `/etc/rancher/k3s/k3s.yaml`
3. cambia `127.0.0.1` por `athenea`
4. lo guarda en `~/.kube/athenea.yaml`

## Uso Local

Como este entorno no usa todavía `~/.kube/config`, la opción más simple es:

`export KUBECONFIG="$HOME/.kube/athenea.yaml"`

De esa manera no hace falta mergear archivos ni tocar un config global.
