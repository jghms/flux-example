# Flux CI/CD Learning Setup

This repository demonstrates a basic Flux v2 setup with automated deployment to Kubernetes.

## Prerequisites

- Docker Desktop with Kubernetes enabled
- `kubectl` CLI
- `flux` CLI (install with `curl -s https://fluxcd.io/install.sh | sudo bash`)
- Git with SSH configured (for GitHub integration)

## Quick Start

### 1. Enable Kubernetes in Docker Desktop

Open Docker Desktop settings and enable Kubernetes. Wait for it to be ready.

### 2. Verify Kubernetes is Running

```bash
kubectl cluster-info
kubectl get nodes
```

### 3. Install Flux

Create a GitHub personal access token with `repo` and `workflow` permissions at https://github.com/settings/tokens

Then install Flux to your cluster:

```bash
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>

flux bootstrap github \
  --owner=$GITHUB_USER \
  --repo=flux-example \
  --path=clusters/local \
  --personal \
  --branch=main
```

This command will:
- Create a fork/use your existing repository
- Install Flux controllers in the `flux-system` namespace
- Create necessary SSH keys and deploy keys
- Begin syncing your cluster with this repository

### 4. Monitor the Sync

```bash
# Watch Flux reconciliation
flux get all --all-namespaces

# Check the demo app deployment
kubectl get pods -n demo
kubectl get services -n demo
```

## Repository Structure

```
.
├── README.md                          # This file
├── clusters/
│   └── local/                         # Cluster-specific configs
│       ├── flux-system/               # Flux system manifests (auto-managed)
│       └── demo/                      # Demo app configuration
└── apps/
    └── demo/                          # Application manifests
        ├── deployment.yaml            # Sample deployment
        └── service.yaml               # Sample service
```

## Understanding Flux

- **GitOps Principles**: All cluster state is defined in Git, and Flux continuously syncs it
- **Kustomization**: Flux uses Kustomize for flexible manifest management
- **Reconciliation**: Flux checks for changes every 10 seconds (configurable)

## Next Steps

1. **Modify the demo app**: Edit `apps/demo/deployment.yaml` and push to Git
2. **Watch Flux sync**: Use `flux get all` or check the deployment changes
3. **Explore Flux documentation**: https://fluxcd.io/docs/

## Troubleshooting

Check Flux logs:
```bash
flux logs --all-namespaces --follow
```

Manually trigger a sync:
```bash
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```

Inspect Kustomization status:
```bash
flux get kustomization -A
```
