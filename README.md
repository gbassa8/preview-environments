# Preview Environments Lab

Este repo es un laboratorio para aprender infraestructura en AWS y levantar entornos de preview por pull request.

La idea es empezar simple:

- una VM en AWS
- `k3s`
- `ArgoCD`
- `Traefik`, `cert-manager`, `ExternalDNS` y `Sealed Secrets`
- una app pequeña para probar todo

Después, cuando entienda bien el flujo, rehacerlo mejor y recién ahí subir una app real.

## Objetivo

Quiero llegar a esto:

- abrir una PR
- construir una imagen
- desplegar un entorno aislado
- tener una URL única para probarlo
- destruir ese entorno al cerrar la PR

## Plan

- [ ] Crear la base en AWS con `Terraform`
- [ ] Instalar `k3s` en una sola VM
- [ ] Añadir los componentes base del clúster
- [ ] Desplegar una app de prueba
- [ ] Automatizar previews por PR
- [ ] Rehacer la estructura con lo aprendido
