# Pushing Charts to Your Helm Repository

Your repository includes a simple script to push custom Helm charts to the local chart repository running in your cluster.

## Quick Start

### 1. Create a new Helm chart

```bash
cd helm-repo/charts
helm create my-app
```

### 2. Customize your chart

Edit the chart files as needed:
- `my-app/Chart.yaml` - Update metadata (name, version, description)
- `my-app/values.yaml` - Set default values
- `my-app/templates/` - Define Kubernetes resources

### 3. Push to the repository

From the repository root:

```bash
./push-chart.sh helm-repo/charts/my-app
```

The script will:
- Package the chart into a `.tgz` file
- Upload it to the ChartMuseum server in your cluster
- Display the chart name and version

### 4. Use the chart in a HelmRelease

Create a new HelmRelease in `apps/my-app-helm/helm-release.yaml`:

```yaml
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: my-app
  namespace: my-app
spec:
  interval: 10s
  chart:
    spec:
      chart: my-app
      version: 0.1.0
      sourceRef:
        kind: HelmRepository
        name: demo-repo
        namespace: flux-system
  values:
    replicaCount: 3
    # ... your custom values
```

Then commit and push to trigger Flux to deploy it.

## Example

A `test-app` chart is already created in `helm-repo/charts/test-app/`. To push it:

```bash
./push-chart.sh helm-repo/charts/test-app
```

Verify it's available:

```bash
helm repo update local
helm search repo test-app
```

## How It Works

- `ChartMuseum` runs in the `helm-repo` namespace and serves charts via HTTP
- The `push-chart.sh` script uses `kubectl cp` to upload `.tgz` files directly to the pod
- Charts are stored in a `PersistentVolume` for persistence
- The `HelmRepository` CRD in Flux automatically syncs the index

## Repository URL

Inside the cluster, the repository is available at:
```
http://helm-repo.helm-repo.svc.cluster.local:8080
```

Locally (with port-forward):
```
http://localhost:8080
```
