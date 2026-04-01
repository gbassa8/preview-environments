#!/usr/bin/env bash
# Cancelar si falla algo
set -eu

mkdir -p "$HOME/.kube"
ssh-keygen -R athenea >/dev/null 2>&1 || true
ssh -o StrictHostKeyChecking=accept-new -i "$HOME/.ssh/arch.pem" ubuntu@athenea "sudo cat /etc/rancher/k3s/k3s.yaml" > "$HOME/.kube/athenea.yaml"
sed -i 's#https://127.0.0.1:6443#https://athenea:6443#' "$HOME/.kube/athenea.yaml"
chmod 600 "$HOME/.kube/athenea.yaml"
