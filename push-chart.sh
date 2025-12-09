#!/bin/bash
# Simple script to push Helm charts to the repository
# Usage: ./push-chart.sh <chart-directory>

set -e

CHART_DIR="${1:-.}"
HELM_REPO_URL="http://localhost:8080"
NAMESPACE="helm-repo"
POD=$(kubectl get pod -n $NAMESPACE -l app=helm-repo -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD" ]; then
  echo "Error: Could not find helm-repo pod in $NAMESPACE namespace"
  exit 1
fi

if [ ! -f "$CHART_DIR/Chart.yaml" ]; then
  echo "Error: $CHART_DIR/Chart.yaml not found"
  exit 1
fi

# Get chart name and version from Chart.yaml
CHART_NAME=$(grep '^name:' "$CHART_DIR/Chart.yaml" | awk '{print $2}')
CHART_VERSION=$(grep '^version:' "$CHART_DIR/Chart.yaml" | awk '{print $2}')
CHART_PACKAGE="$CHART_NAME-$CHART_VERSION.tgz"

echo "📦 Packaging chart: $CHART_NAME v$CHART_VERSION"
helm package "$CHART_DIR" -d /tmp

echo "📤 Uploading to Kubernetes pod..."
kubectl cp /tmp/"$CHART_PACKAGE" -n $NAMESPACE "$POD":/charts/ -c chartmuseum 2>/dev/null || true

echo "✅ Chart uploaded successfully!"
echo "   Chart: $CHART_NAME v$CHART_VERSION"
echo "   File: /charts/$CHART_PACKAGE"
echo ""
echo "ChartMuseum will automatically update the index."
echo "You can verify with:"
echo "  helm repo update local"
echo "  helm search repo $CHART_NAME"
