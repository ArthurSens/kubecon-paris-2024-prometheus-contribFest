#!/bin/bash
set -eufo pipefail
export SHELLOPTS	# propagate set to children by default
IFS=$'\t\n'

echo "# Checking that all dependnecies are installed"
command -v docker >/dev/null 2>&1 || { echo 'Please install docker'; exit 1; }
command -v kind >/dev/null 2>&1 || { echo 'Please install kind'; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo 'Please install kubectl'; exit 1; }
command -v go >/dev/null 2>&1 || { echo 'Please install go'; exit 1; }
echo "# All dependencies installed"

KIND_CONFIG_FILE='kind/kind-config.yml'

# Starts a local Kubernetes cluster with Kind if it doesn't exist.
if ! kind get clusters | grep -q '^kubecon2024-prometheus$'
then
    VERY_VERY_VERBOSE=2147483647
    kind create cluster \
      --name kubecon2024-prometheus \
      --image kindest/node:v1.29.2 \
      --config "$KIND_CONFIG_FILE" \
      --verbosity "$VERY_VERY_VERBOSE" \
      --wait 30s \
      --retain \
    || (docker ps && docker exec -t kubecon2024-prometheus-control-plane ss -tunlp && exit 1)
fi
echo "# Cluster is running"

# Points the demo manifest at your Kind cluster.
if ! DEMO_API_SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[?(@.name == "kind-kubecon2024-prometheus")].cluster.server}')
then
    echo "kind-kubecon2024-prometheus cluster does not exist!"
    exit 1
fi

docker ps
echo "Api Server at '$DEMO_API_SERVER'"
