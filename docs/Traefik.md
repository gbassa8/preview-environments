# Traefik

## Qué Se Hizo

En este cluster, `Traefik` estaba publicando la IP privada del nodo en `Ingress.status.loadBalancer`.

Eso rompía el flujo con `ExternalDNS`, porque tomaba esa IP privada y la publicaba en Cloudflare.

Para corregirlo:

- `Terraform` lee la `Elastic IP` a partir de `eip_allocation_id`
- Esa IP se inyecta en `cloud-init`
- `cloud-init` crea un `HelmChartConfig` de `Traefik`
- `Traefik` publica la IP pública correcta en el status de los `Ingress`

## Por Qué Importa

Con esto:

- `ExternalDNS` puede leer el `Ingress` sin `target` manual
- Los registros DNS apuntan a la IP pública correcta
- No hace falta hardcodear la IP en los manifests de las apps
