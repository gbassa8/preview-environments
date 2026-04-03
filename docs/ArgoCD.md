# ArgoCD

## Rol En El Proyecto

`ArgoCD` es la capa que maneja lo que vive dentro de Kubernetes.

La separación actual es:

- `Terraform` levanta la infraestructura en AWS
- `cloud-init` prepara la VM e instala `k3s` + `Tailscale`
- `ArgoCD` sincroniza el estado del cluster desde git

La idea es que, después de instalar `ArgoCD`, los componentes del cluster no se agreguen a mano sino desde este repo.

En este repo se va a usar un patrón simple de app-of-apps: una `Application` raíz apunta al path principal de GitOps y desde ahí ArgoCD crea y sincroniza las aplicaciones hijas del cluster.

## Instalación 

Con el setup actual, el flujo queda así:

1. `terraform apply`
2. Script para recuperar kubeconfig
3. Script para instalar `ArgoCD`
4. El script corre `kubectl apply -f gitops/app-of-apps.yaml`
5. `ArgoCD` sincroniza `gitops/apps`

Eso evita reinstalar a mano los componentes del cluster después de cada `destroy/apply`.

## Acceso Inicial

Para entrar rápido a la UI, usar port-forward:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Abrir `https://localhost:8080`

Usuario: `admin`

Password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
