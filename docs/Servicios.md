# Servicios

## Estado Actual

El patrón actual para agregar servicios a este repo quedó así:

- Una base reusable en `gitops/services/<servicio>/base`
- Un overlay de producción en `gitops/services/<servicio>/prod`
- Una `Application` de ArgoCD en `gitops/apps/<servicio>.yaml`
- Si el servicio tiene previews, un `ApplicationSet` en `gitops/apps/<servicio>-preview.yaml`

La convención de naming para previews sigue `docs/Naming.md`.

### 1. Base

En `gitops/services/<servicio>/base` va lo común:

- `Deployment`
- `Service`
- `Ingress`
- `ConfigMap` si aplica

La idea es que esta base no quede atada a un solo entorno.

### 2. Producción

En `gitops/services/<servicio>/prod` va el overlay estable:

- namespace fijo
- imagen de producción
- cualquier ajuste propio de prod

### 3. ArgoCD

En `gitops/apps/<servicio>.yaml` va la `Application` que apunta al overlay de prod.

Si el servicio necesita previews, en `gitops/apps/<servicio>-preview.yaml` va el `ApplicationSet` con generador por pull requests.

## Qué Necesita El CI Del Servicio

Este repo de infra asume que el CI vive en el repo de cada servicio.

Ejemplo concreto: `simon-game/.github/workflows/`.

El contrato esperado es este:

- Construir una imagen deployable de la app
- Publicarla en un registry accesible desde Kubernetes
- Publicar un tag de producción que después pueda referenciarse desde `gitops/services/<servicio>/prod`
- Si el servicio tiene previews, publicar también una imagen por PR con un tag predecible para que el `ApplicationSet` la pueda resolver
- Si el servicio usa base de datos, correr creación de schema y cleanup fuera del cluster
- Actualizar este repo cuando cambie la imagen de producción, para que `ArgoCD` vea el drift y sincronice

En otras palabras:

- El CI del servicio es dueño del artifact
- El CI del servicio es dueño del lifecycle de recursos externos como DB o registry
- Este repo de infra es dueño solo del estado deseado dentro de Kubernetes

No es requisito que todos los servicios tengan el mismo workflow, pero sí que cumplan ese contrato.
