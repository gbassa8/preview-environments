# Naming

## Preview Environments

Para previews, la convención elegida es esta:

- host: `{{branch_slug}}.preview.midominio.com`
- namespace: `<app>-pr-<numero>`
- app de ArgoCD: `<app>-preview-<numero>`

Ejemplo:

- app: `portal`
- PR: `42`
- branch: `feature/login-fix`

Resultado:

- host: `feature-login-fix.preview.midominio.com`
- namespace: `portal-pr-42`
- app de ArgoCD: `portal-preview-42`

## Por Qué Así

El host usa `branch_slug` porque queda más legible para humanos.

El namespace y la app de ArgoCD usan `app + pr` para evitar colisiones en un cluster con más de una app.

`pr-42` solo no alcanza si existen varias apps con PR `42` al mismo tiempo.

## Nota

Si cambia el nombre de la branch, cambia el host de la preview.

El namespace y la app de ArgoCD siguen atados al número de PR, que es más estable para lifecycle y cleanup.

## Labels

Conviene que cada preview también tenga labels consistentes.

Sugeridas:

- `app.kubernetes.io/name: <app>`
- `preview: "true"`
- `pr-number: "<numero>"`
- `branch-slug: <branch_slug>`

Esto sirve para:

- buscar recursos rápido
- filtrar previews
- limpiar recursos
- entender ownership más fácil
