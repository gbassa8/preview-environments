# ArgoCD

- `Terraform` levanta la base en AWS
- `cloud-init` prepara la VM
- `ArgoCD` instala y mantiene lo que vive dentro de Kubernetes

Eso incluye:

- `cert-manager`
- `ExternalDNS`
- `Sealed Secrets`
- Aplicaciones
- Más adelante preview environments

## Workflow

Sin `ArgoCD`, cada vez que haga `destroy/apply` de terraform voy a tener que reinstalar el software del cluster a mano.

Con `ArgoCD`, el flujo pasa a ser:

1. Levantar la VM y `k3s`
2. Recuperar kubeconfig
3. Instalar `ArgoCD`
4. Dejar que `ArgoCD` instale el resto

## Acceso Inicial

Para entrar, usar port-forward:

```bash
kubectl -n argocd port-forward svc/argocd-server 8080:443
```

Abrir `https://localhost:8080`

Usuario: `admin`

Password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```
