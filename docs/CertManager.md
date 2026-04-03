# Cert Manager

## Rol En El Proyecto

`cert-manager` es la capa que resuelve TLS dentro del cluster.

Cuando quede instalado y funcionando, el flujo va a ser este:

- `Traefik` expone una app
- `cert-manager` pide el certificado
- Let's Encrypt valida el dominio
- `cert-manager` guarda el certificado en un `Secret`
- `Traefik` sirve HTTPS con ese secret

En este proyecto, `cert-manager` va a trabajar con:

- Let's Encrypt para emitir certificados
- Cloudflare para resolver el challenge DNS

La validación elegida es `DNS-01` con `Cloudflare`, porque encaja mejor con subdominios y preview environments.

## Instalación

Con el setup actual, la idea es que el flujo quede así:

1. `terraform apply`
2. Script para recuperar kubeconfig
3. Script para instalar `ArgoCD`
4. El script corre `kubectl apply -f gitops/app-of-apps.yaml`
5. `ArgoCD` sincroniza `gitops/apps`
6. `cert-manager` se instala desde GitOps
7. Se agrega el secret de Cloudflare
8. Se crea un `ClusterIssuer`
9. Se prueba la emisión de un certificado real

Para este proyecto conviene usar `ClusterIssuer` y no `Issuer`, porque la configuración tiene que servir para varios namespaces y más adelante para previews.

## Token De Cloudflare

Para resolver `DNS-01`, `cert-manager` necesita un API token de Cloudflare con permisos mínimos sobre la zona.

Permisos:

- `Zone:DNS:Edit`
- `Zone:Zone:Read`

Alcance:

- solo la zona que se va a usar, por ejemplo `midominio.com`

Paso a paso en Cloudflare:

1. Entrar a Cloudflare.
2. Ir a `Profile` -> `API Tokens`.
3. Click en `Create Token`.
4. Elegir `Create Custom Token`.
5. Poner un nombre, por ejemplo `cert-manager-midominio-com`.
6. Agregar permisos `Zone` -> `DNS` -> `Edit`.
7. Agregar permisos `Zone` -> `Zone` -> `Read`.
8. En `Zone Resources`, elegir `Include` -> `Specific zone` -> `midominio.com`.
9. Revisar que no tenga más permisos ni más zonas.
10. Click en `Create Token`.
11. Copiar el token en ese momento, porque Cloudflare no lo vuelve a mostrar completo.

Después, guardarlo en Kubernetes como un `Secret` en el namespace `cert-manager`.

Por ahora, la opción más simple es crearlo a mano con `kubectl`:

```bash
kubectl -n cert-manager create secret generic cloudflare-api-token \
  --from-literal=api-token="$CLOUDFLARE_API_TOKEN"
```

Esto es temporal.

La idea más adelante es resolver secretos de una forma más completa, para no depender de creación manual después de recrear la infra.

## Estado Esperado

Al terminar esta etapa debería existir esto en el cluster:

- `cert-manager` instalado y sano
- un secret con el token de Cloudflare
- un `ClusterIssuer` listo
- al menos un certificado emitido correctamente
- un `Secret` TLS generado por `cert-manager`

Validaciones mínimas:

```bash
kubectl get clusterissuer
kubectl get certificate -A
kubectl get secret -A
```

Y en concreto:

- el `ClusterIssuer` tiene que quedar en `Ready`
- el `Certificate` tiene que emitirse bien
- el `Secret` TLS tiene que existir

## Por Qué Importa

Esto es lo que deja al cluster listo para exponer apps con HTTPS real.

También deja preparada una pieza importante para preview environments, donde cada PR va a necesitar su propio subdominio.

Sin `cert-manager`, eso implicaría manejar TLS a mano o aceptar entornos sin HTTPS.

## Resumen

En este setup:

- `ArgoCD` mantiene la configuración desde git
- `ExternalDNS` crea registros DNS
- `cert-manager` resuelve TLS
- `Traefik` expone la app al usuario final

El resultado final de esta etapa es que una app del cluster puede salir con HTTPS válido sin manejo manual de certificados.
