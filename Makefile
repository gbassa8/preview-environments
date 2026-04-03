.PHONY: bootstrap

bootstrap:
	terraform -chdir=terraform apply
	bash scripts/get-kubeconfig.sh
	bash scripts/install-argocd.sh
	bash scripts/restore-sealed-secrets-key.sh
