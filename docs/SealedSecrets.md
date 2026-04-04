# Sealed Secrets

## Por Qué Usarlo

`Sealed Secrets` permite guardar secretos en git sin guardar el valor en claro.

La idea es simple:

- en el repo vive un `SealedSecret`
- en el cluster corre un controller que lo desencripta
- el resultado real es un `Secret` normal de Kubernetes

Eso encaja bien con `ArgoCD`, porque deja manejar secretos desde GitOps sin subir tokens o passwords en texto plano.

## El Problema Con Destruir El Cluster

`Sealed Secrets` usa una key privada para desencriptar los secretos.

Por default, esa key vive adentro del cluster.

Entonces, si el cluster se destruye:

- se pierde la key privada
- el cluster nuevo genera otra key distinta
- los `SealedSecret` viejos ya no se pueden desencriptar

En ese escenario, los secretos no se recuperan solos. Habría que volver a crear los secretos originales y volver a sellarlos con la key nueva.

Para este proyecto esto pasa seguido, porque el flujo actual incluye `destroy/apply` con frecuencia.

## Solución

No depender de una key generada adentro del cluster.

En vez de eso:

1. Se genera una key de `Sealed Secrets` una sola vez.
2. Esa key se guarda fuera del cluster, en AWS.
3. En el bootstrap del cluster, un script recupera esa key y crea el `Secret` que usa el controller.
4. Después `ArgoCD` instala `Sealed Secrets`.
5. El controller levanta usando esa misma key.
6. `ArgoCD` aplica los `SealedSecret` del repo.
7. El controller los desencripta y recrea los `Secret` reales.

Con este enfoque, si el cluster muere:

- se recrea el cluster
- se restaura la misma key
- `ArgoCD` vuelve a sincronizar
- los secretos se recuperan

## Setup De La Key

La key se genera una sola vez, fuera del cluster.

```bash
openssl req -x509 -nodes -newkey rsa:4096 \
  -keyout sealed-secrets.key \
  -out sealed-secrets.crt \
  -days 3650 \
  -subj "/CN=sealed-secrets/O=sealed-secrets"
```

Eso genera:

- `sealed-secrets.key`
- `sealed-secrets.crt`

## Guardarlo En AWS

```bash
aws secretsmanager create-secret \
  --name preview-environments/sealed-secrets-key \
  --secret-string "$(jq -n \
    --rawfile tls_crt sealed-secrets.crt \
    --rawfile tls_key sealed-secrets.key \
    '{"tls.crt": $tls_crt, "tls.key": $tls_key}')"
```

Para actualizarlo si ya existe:

```bash
aws secretsmanager put-secret-value \
  --secret-id preview-environments/sealed-secrets-key \
  --secret-string "$(jq -n \
    --rawfile tls_crt sealed-secrets.crt \
    --rawfile tls_key sealed-secrets.key \
    '{"tls.crt": $tls_crt, "tls.key": $tls_key}')"
```

## Restaurarlo En El Cluster

En el bootstrap del cluster, antes de que `Sealed Secrets` empiece a desencriptar cosas, hay que restaurar esa key como `Secret` TLS de Kubernetes. 

Existe un script para restaurar el secret. Ese `Secret` es el que después usa el controller.

## Cómo Crear Un SealedSecret

```bash
kubectl -n namespace create secret generic mi-secret \
  --from-literal=clave=valor \
  --dry-run=client -o yaml \
  | kubeseal \
    --controller-name sealed-secrets \
    --controller-namespace sealed-secrets \
    -o yaml > mi-secret-sealed.yaml
```

Después, el archivo `mi-secret-sealed.yaml` es el que se guarda en git.

Cuando el controller lo vea, va a crear el `Secret` real dentro del cluster.
