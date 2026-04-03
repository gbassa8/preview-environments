#!/usr/bin/env bash
set -eu

aws secretsmanager get-secret-value \
  --secret-id preview-environments/sealed-secrets-key \
  --query SecretString \
  --output text > sealed-secrets-key.json

jq -r '."tls.crt"' sealed-secrets-key.json > sealed-secrets.crt
jq -r '."tls.key"' sealed-secrets-key.json > sealed-secrets.key

kubectl create namespace sealed-secrets

kubectl -n sealed-secrets create secret tls sealed-secrets-key \
  --cert=sealed-secrets.crt \
  --key=sealed-secrets.key

kubectl -n sealed-secrets label secret sealed-secrets-key \
  sealedsecrets.bitnami.com/sealed-secrets-key=active \
  --overwrite

rm -f sealed-secrets-key.json sealed-secrets.crt sealed-secrets.key
