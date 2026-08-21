# dieubernetes

GitOps manifests for a multi-cluster DigitalOcean Kubernetes (DOKS) platform.
ArgoCD reconciles every cluster from this repo's `main`. Sibling repos:
`terraform` (provisioning) and `dieuctl` (the platform CLI).

## Layout

- `argocd/apps/` — ApplicationSets, grouped by layer. A `root` app-of-apps (applied
  out-of-band, not in this repo) watches this directory with `prune: true`, so adding
  or deleting an appset file here creates or tears down the corresponding Applications.
  - `bootstrap/` — Gateway API CRDs (standard channel).
  - `infrastructure/` — `appset.yaml` (matrix: clusters x [kube-prometheus-stack,
    metrics-server, cert-manager, cilium-gateway, external-dns, external-secrets]) plus
    `envoy-gateway-appset.yaml` (standalone; being removed, see PR #31).
  - `platform/` — kargo, kargo-pipelines, cluster-registrations.
  - `workloads/` — mealie, plausible, changedetection.
- `charts/{infrastructure,platform,workloads}/<name>/` — one Helm chart per component.
  Vendored upstream charts live as subchart dependencies with our values on top.
- `clusters/<cluster>/overrides/<app>.yaml` — per-cluster value overrides. Appsets load
  `values.yaml` then `$values/clusters/{{ .name }}/overrides/{{ .app }}.yaml`
  (`ignoreMissingValueFiles: true`), so an override is optional per app per cluster.

## Clusters

Registered ArgoCD clusters: `platform-do-atl1` (runs ArgoCD + Kargo) and
`stage-do-atl1` (workloads). `prod-do-atl1` exists in terraform but is not registered
in ArgoCD yet. kubeconfig contexts are `do-atl1-dieubernetes-<cluster>-do-atl1`.

## Ingress

Cilium's native Gateway API is the gateway. Workload HTTPRoutes `parentRef` the
`cilium-gateway-system/public` Gateway. The Gateway adopts a terraform-created DO load
balancer via the `kubernetes.digitalocean.com/load-balancer-id` annotation (set in the
cluster's `cilium-gateway.yaml` override). cert-manager issues TLS; external-dns
publishes records to Cloudflare (zone `dieu.dev`).

## Conventions and gotchas

- **ArgoCD syncs from `main` only** (`targetRevision: HEAD`). Changes reach clusters
  only after merge. Test-on-cluster-without-merge means pausing auto-sync on the shared
  platform cluster, which needs explicit human authorization.
- **external-dns needs a unique `txtOwnerId` per cluster.** All instances share the
  `dieu.dev` zone with `policy=sync`; a shared owner-id makes one cluster delete the
  records another created. Set it in each cluster's `external-dns.yaml` override.
- **Commit signing is via 1Password** (`op-ssh-sign`) and can intermittently refuse.
  Fallbacks: `git commit --no-gpg-sign` to capture, then `--amend -S` once 1Password is
  unlocked; if SSH push also refuses, push over HTTPS with `gh auth token`.
- **A pre-push hook runs `helm lint` + `kubeconform` on every chart** and blocks the push
  if any fails. Keep charts template-clean.
- Prefer editing a chart's `values.yaml` (or a per-cluster override) over touching the
  vendored subchart.

## Adding things

- New workload: add `charts/workloads/<name>/` (with an HTTPRoute parenting
  `cilium-gateway-system/public` if it needs ingress); the workloads appset generates it
  across clusters. Add a cluster override only if needed.
- New infra component: add `charts/infrastructure/<name>/` and a list entry in
  `argocd/apps/infrastructure/appset.yaml` (or a standalone appset if it needs
  non-templatable settings, as envoy-gateway did for `skipCrds`).
