# Preview Environments Lab

Este repo es un laboratorio para aprender infraestructura en AWS y levantar entornos de preview por pull request.

## Objetivo

Quiero llegar a esto:

- Abrir un PR
- Construir una imagen
- Desplegar un entorno aislado
- Tener una URL única para probarlo
- Destruir ese entorno al cerrar el PR

## Plan

- [x] Base reproducible en AWS con `Terraform` + `k3s`
- [x] Acceso privado y manejo local del cluster
- [ ] `cert-manager`, `ExternalDNS`, `ArgoCD`, `Sealed Secrets`
- [ ] GitOps
- [ ] App de prueba con DNS y TLS
- [ ] `Supabase` para bases de datos
- [ ] Preview environments por pull request
- [ ] Flujo completo con una app real
