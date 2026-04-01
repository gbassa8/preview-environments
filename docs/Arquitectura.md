# Arquitectura

Seis componentes:

1. AWS como base de infraestructura
2. Una VM con `k3s`
3. Servicios dentro del cluster
4. Servicios externos
5. GitOps y CI/CD
6. Aplicaciones

## AWS

Infraestructura mínima para el cluster:

- Una instancia EC2
- Red y reglas de acceso
- Una IP pública estable
- Almacenamiento para la VM

## Cluster

Sobre la VM corre un cluster k3s con un solo nodo

## Servicios

Servicios necesarios para operar el sistema:

- Traefik para exponer tráfico HTTP/HTTPS
- cert-manager para emitir y renovar certificados TLS
- ExternalDNS para los registros DNS
- ArgoCD para sincronizar el estado desde git
- Sealed Secrets para manejar secretos

## Servicios Externos

Servicios fuera del cluster:

- Cloudflare para DNS publico
- GHCR para guardar las imagenes
- Tailscale para acceso privado de administracion
- Supabase como base de datos externa cuando la app lo necesite

Supabase no es obligatorio si la app de prueba es stateless.
En la version con previews reales, probar una sola instancia de Supabase
con aislamiento por schema en lugar de una base completa por PR.

## GitOps Y CI/CD

Dos flujos:

- GitHub como origen de codigo y manifiestos
- GitHub Actions para construir y publicar imagenes

ArgoCD toma el estado deseado desde git y lo aplica en el cluster.

El acceso administrativo al server y al API server del cluster viaja por la red privada de Tailscale, no por puertos administrativos publicos.

## Aplicaciones

Las aplicaciones se despliegan en Kubernetes y se publican a traves de ingress.

Existe una aplicación estable y, cuando haga falta, entornos temporales de preview.

## Entornos De Preview

Cada pull request puede crear una instancia aislada de la aplicación.

El modelo base es:

- Un namespace por PR
- Una URL por PR
- Una imagen por commit
- Eliminacion automatica al cerrar el PR
