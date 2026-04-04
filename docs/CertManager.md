# Cert Manager

## Rol En El Proyecto


`cert-manager` es la capa que resuelve TLS dentro del cluster. Dejando al cluster listo para exponer apps con HTTPS real.

Sin `cert-manager`, eso implicaría manejar TLS a mano o aceptar entornos sin HTTPS.

Cuando quede instalado y funcionando, el flujo va a ser este:

- `Traefik` expone una app
- `cert-manager` pide el certificado
- Let's Encrypt valida el dominio
- `cert-manager` guarda el certificado en un `Secret`
- `Traefik` sirve HTTPS con ese secret

La validación elegida es `DNS-01` con `Cloudflare`, porque encaja mejor con subdominios y preview environments.

## Token De Cloudflare

Para resolver `DNS-01`, `cert-manager` necesita un API token de Cloudflare con permisos mínimos sobre la zona.

Permisos:

- `Zone:DNS:Edit`
- `Zone:Zone:Read`

Alcance:

- solo la zona que se va a usar, por ejemplo `midominio.com`
