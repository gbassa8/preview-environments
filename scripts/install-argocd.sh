#!/usr/bin/env bash
set -eu


kubectl create namespace argocd
kubectl apply --server-side -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Esperar a que termine de instalarse argocd
kubectl -n argocd rollout status deploy/argocd-server
kubectl -n argocd rollout status deploy/argocd-repo-server

kubectl apply -f gitops/apps/app-of-apps.yaml
