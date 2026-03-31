# k3s Preview Environments Plan

## Goal

Build a self-managed `k3s` platform first, learn the stack properly, then add GitOps-driven preview environments, and only after that onboard this project.

This follows two ideas from the references:

- Learn Kubernetes fundamentals first: cluster basics, namespaces, labels, workloads, ingress, debugging.
- Build preview environments GitOps-style: isolated env per PR, unique URL, automated create/update/destroy.

## Guiding Principles

- Use `Terraform` for AWS infra only.
- Use `k3s`, not `minikube`, for the real lab.
- Start with one small VM and one toy app.
- Treat the first setup as disposable.
- Rebuild once after learning pain points.
- Use `GHCR` for images.
- Use `Cloudflare` for DNS.
- Keep external services explicit: `GitHub`, `GHCR`, `Cloudflare`, and optionally `Supabase`.
- Keep the first preview-env version simple.
- Do not use this repo as the first workload.

## Phase 0 - Scope and Guardrails

Define the target clearly before touching infra.

- Goal: one self-managed `k3s` cluster with GitOps and PR preview envs.
- Use `Terraform` for the AWS foundation only.
- Use a single-node cluster first; no HA.
- Use `ArgoCD`, `Traefik`, `cert-manager`, `ExternalDNS`, and `Sealed Secrets`.
- Use a toy stateless app first; add `Supabase` only when the app needs data.
- Keep this project for a later onboarding phase.

## Phase 0.5 - Provision AWS Foundation With `Terraform`

Create the minimum reproducible AWS layer before installing Kubernetes.

Scope:

- One VM / instance.
- One security group.
- One static public IP if used.
- Variables and outputs for region, instance type, SSH access, and public address.

Non-goals:

- Do not manage in-cluster apps with `Terraform`.
- Do not manage `ArgoCD`, `cert-manager`, or app manifests with `Terraform`.
- Do not over-engineer modules early.

Tasks:

- Create a small `Terraform` project for AWS infra.
- Provision the VM and network access needed for SSH, HTTP, and HTTPS.
- Expose outputs for SSH and public endpoint details.
- Keep bootstrap separate: `Terraform` creates infra, bootstrap scripts install `k3s`.

Deliverable:

- Reproducible AWS foundation that can be destroyed and recreated cleanly.

Estimated time:

- `0.5 day`

## Phase 1 - Kubernetes Headstart

Learn enough fundamentals to avoid cargo-culting manifests.

Topics:

- cluster fundamentals
- control plane vs worker nodes
- managed vs self-managed clusters
- `etcd` basics
- how `kubectl` talks to the API server
- pods, deployments, services, ingress
- namespaces, labels, selectors
- configmaps and secrets
- resource requests and limits
- probes, rollouts, logs, restarts

Deliverable:

- Ability to explain core resources and debug a broken pod/deployment.

Estimated time:

- `1-2 days`

## Phase 2 - Bootstrap the VM and `k3s`

Set up the first real cluster.

Tasks:

- Apply `Terraform` to provision one VM with enough headroom.
- Install `k3s`.
- Install local tooling: `kubectl`, `kubectx`, `kubens`.
- Verify node health and default storage.
- Check bundled `Traefik`; keep it initially for simplicity.
- Deploy a small test workload to confirm the cluster is usable.

Deliverable:

- Reachable cluster, healthy node, working test deployment.

Estimated time:

- `0.5-1 day`

## Phase 3 - Install Platform Add-ons

Install core platform services in this order:

1. `cert-manager`
2. `ExternalDNS` with Cloudflare
3. `ArgoCD`
4. `Sealed Secrets`

Why this order:

- First get ingress, DNS, and TLS working.
- Then add GitOps.
- Then add secret management.

Tasks:

- Configure DNS records through Cloudflare.
- Configure automatic TLS certificate issuance.
- Install `ArgoCD` and validate sync from git.
- Install `Sealed Secrets` and validate decryption inside cluster.

Deliverable:

- Domain resolves to cluster.
- TLS works.
- `ArgoCD` syncs apps from git.
- Sealed secret workflow works.
- `Cloudflare` and `GHCR` are connected to the platform flow.

Estimated time:

- `1-3 days`

## Phase 4 - Create the GitOps Repo Structure

Set up the repo layout that `ArgoCD` will manage.

Recommended shape:

- `clusters/`
- `apps/`
- `base/`
- `overlays/`

Approach:

- Start with plain manifests plus `Kustomize`.
- Keep the first structure boring and obvious.
- Avoid overusing Helm early.
- Add app-of-apps only after the first app works.

Expected reality:

- The first version will probably be reorganized once after learning.

Deliverable:

- Clean initial GitOps repo structure for cluster bootstrap and app deployment.

Estimated time:

- `1 day`
- plus likely `0.5-1 day` refactor later

## Phase 5 - Deploy a Toy App End to End

Use a tiny stateless app as the first workload.

Data strategy:

- v1: no database if possible
- v2: add external data only if the app needs it
- if preview data isolation is needed later, prefer one `Supabase` project with separate schemas over a full database per PR

Tasks:

- Build a small demo app.
- Containerize it.
- Push image to `GHCR`.
- Deploy it via `ArgoCD`.
- Expose it through `Traefik`.
- Issue TLS with `cert-manager`.
- Create DNS with `ExternalDNS`.

This is the first full pass through the platform.

Deliverable:

- Public URL with valid cert.
- Git commit triggers sync.
- App updates through GitOps.

Estimated time:

- `0.5-1 day`

## Phase 6 - Rebuild It Better

Redo the setup after learning from the first pass.

Tasks:

- Tighten namespace usage.
- Standardize labels and annotations.
- Clean up `Kustomize` bases and overlays.
- Improve image tag strategy.
- Improve `ArgoCD` app layout.
- Reduce duplication.
- Write bootstrap documentation.

Purpose:

- First pass teaches pain.
- Second pass teaches design.

Deliverable:

- Reproducible cluster state and a cleaner repo layout.

Estimated time:

- `1-3 days`

## Phase 7 - Define the Preview Environment Pattern

Design the preview model before automating it.

Recommended pattern:

- One namespace per PR: `pr-123`
- One URL per PR: `pr-123.preview.yourdomain.com`
- One image tag per commit SHA
- One app instance per PR
- Auto destroy on PR close

Important details:

- Use namespace isolation first.
- Label resources with things like `preview=true` and `pr=123`.
- Keep config templated and minimal.
- Do not start with full per-PR databases.
- If data isolation becomes necessary, prefer per-PR schemas in `Supabase` before more complex database provisioning.

Deliverable:

- Explicit preview environment contract and resource model.

Estimated time:

- `0.5 day`

## Phase 8 - Automate Preview Environments

Implement PR lifecycle automation.

Events:

- PR opened
- PR synchronized
- PR closed

Tasks:

- Build image in GitHub Actions.
- Push image to `GHCR`.
- Generate or update preview config.
- Let `ArgoCD` sync the preview app.
- Post preview URL back to the PR.
- Delete preview namespace/app on PR close.
- If the app needs data, create and clean up the matching schema in `Supabase`.

Safer progression:

- v1: GitHub Action updates preview config in git.
- v2: Move to `ApplicationSet` PR generator if it actually helps.

Deliverable:

- Open PR -> preview URL.
- Push commit -> preview updates.
- Close PR -> preview destroyed.

Estimated time:

- Simple version: `2-4 days`
- Cleaner `ApplicationSet` version: `+1-3 days`

## Phase 9 - Onboard This Project

Only do this after toy-app previews work.

Repo-specific work likely needed:

- Split concerns: web, worker, Redis.
- Decide what runs in previews.
- Start with web-only previews.
- Disable or stub heavy flows where needed.
- Make `APP_BASE_URL` work with dynamic preview URLs.
- Handle auth redirect/origin issues.
- Decide what to do with local file storage.
- Decide whether worker is disabled, shared, or per-preview.

Recommended first cut for this repo:

- web only
- shared dev `Supabase` or isolated schema
- no Gmail in preview
- no full background jobs unless truly needed

Deliverable:

- This project runs in the cluster with a reduced preview profile.

Estimated time:

- `3-7 days` first cut

## Phase 10 - Hardening

After previews work, make the platform less fragile.

Tasks:

- Add resource requests and limits.
- Add namespace quotas.
- Add preview TTL cleanup.
- Add image retention policy.
- Add alerts or uptime checks.
- Improve docs for rebuild, backup, and restore.
- Add safeguards so one bad preview burst does not kill the VM.

Deliverable:

- More stable cluster and less preview sprawl.

Estimated time:

- `1-3 days`

## Suggested Order

Strict order:

1. Learn the basics.
2. Provision AWS foundation with `Terraform`.
3. Bootstrap `k3s`.
4. Install platform add-ons.
5. Deploy toy app.
6. Rebuild cleaner.
7. Add preview-env automation for toy app.
8. Onboard this project.
9. Add preview envs for this project.

## What Not to Do Early

- No `minikube` on the real VM.
- No multi-node cluster.
- No HA control plane.
- No service mesh.
- No self-hosted registry.
- No managing in-cluster resources with `Terraform`.
- No full per-PR database provisioning.
- No Helm everywhere.
- No using this repo as the first workload.

## Realistic Timeline

- AWS foundation + base `k3s` platform usable: `3.5-7 days`
- Clean second-pass GitOps setup: `+2-5 days`
- Preview envs on toy app: `+2-4 days`
- This project onboarded to cluster: `+3-7 days`
- This project with preview envs: `+3-7 days`

Total rough timeline:

- Learning + platform + toy previews: `1.5-3 weeks`
- Plus this project: `another 1-2 weeks`

## Definition of Done

- AWS infra is reproducible via `Terraform`.
- Single-node `k3s` cluster is reproducible.
- `ArgoCD` manages apps declaratively.
- DNS and TLS are automatic.
- Image flow uses `GHCR`.
- External services are part of the design: `GitHub`, `GHCR`, `Cloudflare`, and `Supabase` when needed.
- PR creates namespace and URL automatically.
- PR close destroys preview automatically.
- At least one toy app works end to end.
- This project runs with a reduced preview profile.

## Main Risks

- `Terraform` drift from manual AWS changes.
- Weak VM resources.
- Bad first GitOps repo structure.
- Cloudflare token or DNS misconfig.
- `cert-manager` DNS challenge issues.
- Preview namespace sprawl.
- This project's worker, files, and OAuth complexity.

## Recommended Execution Notes

- Use a toy app first, no compromise.
- Treat the first setup as disposable.
- Document every manual bootstrap step while doing it.
- Only after the second pass should this project enter the cluster.

## Unresolved Questions

- One VM only?
- Which domain/subdomain?
- Toy app first ok?
- Web-only previews first ok?
- `ApplicationSet` now or later?
