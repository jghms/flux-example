# Pushing Charts to Your Helm Repository

Your repository includes two methods to push custom Helm charts to the ChartMuseum server running in your cluster.

## Method 1: Using the push-chart.sh Script (Recommended)

This is the simplest method that works reliably.

### Quick Start

#### 1. Create a new Helm chart

```bash
cd helm-repo/charts
helm create my-app
```

#### 2. Customize your chart

Edit the chart files as needed:
- `my-app/Chart.yaml` - Update metadata (name, version, description)
- `my-app/values.yaml` - Set default values
- `my-app/templates/` - Define Kubernetes resources

#### 3. Push to the repository

From the repository root:

```bash
./push-chart.sh helm-repo/charts/my-app
```

The script will:
- Package the chart into a `.tgz` file
- Upload it to the ChartMuseum server in your cluster
- Display the chart name and version

**Note:** After pushing with this method, you need to restart the ChartMuseum pod for it to pick up the new chart:
```bash
kubectl delete pod -n helm-repo -l app=helm-repo
```

## Method 2: Using helm cm-push Plugin

You can also use the `helm-push` plugin for a more native Helm experience.

### Setup (one-time)

1. Install the helm-push plugin if not already installed:
```bash
helm plugin install https://github.com/chartmuseum/helm-push.git
```

2. Set up port-forwarding to access ChartMuseum locally:
```bash
kubectl port-forward svc/helm-repo -n helm-repo 8080:8080
```

3. Add the local repository:
```bash
helm repo add local http://localhost:8080
```

### Push a Chart

```bash
cd helm-repo/charts
helm cm-push my-app local --force
```

The `--force` flag allows overwriting existing chart versions.

**Note:** This method also requires restarting the ChartMuseum pod to regenerate the index:
```bash
kubectl delete pod -n helm-repo -l app=helm-repo
```

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
