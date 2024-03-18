#!/bin/bash
set -eufo pipefail
export SHELLOPTS	# propagate set to children by default

IFS=$'\t\n'

KIND_CONFIG_FILE='kind-config.yml'
CLUSTER_NAME=kubecon2024-prometheus

echo -n "# Checking if all Kubernetes dependencies are installed..."
command -v docker >/dev/null 2>&1 || { echo 'Please install docker (docker + https://github.com/abiosoft/colima on MacOS works well if Docker Desktop license does not work for you'; exit 1; }
command -v go >/dev/null 2>&1 || { echo 'Please install go (https://go.dev/doc/install)'; exit 1; }
command -v kind >/dev/null 2>&1 || { echo 'Please install kind (go install sigs.k8s.io/kind@v0.22.0)'; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo 'Please install kubectl (https://kubernetes.io/docs/tasks/tools/#kubectl)'; exit 1; }
echo "OK!"

# Starts a local Kubernetes cluster with Kind if it doesn't exist.
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"
then
    VERY_VERY_VERBOSE=2147483647
    kind create cluster \
      --name ${CLUSTER_NAME} \
      --image kindest/node:v1.29.2 \
      --config "$KIND_CONFIG_FILE" \
      --verbosity "$VERY_VERY_VERBOSE" \
      --wait 30s \
      --retain \
    || (docker ps && docker exec -t ${CLUSTER_NAME}-control-plane ss -tunlp && exit 1)
fi

CLUSTER_API_URL=$(kubectl config view --minify -o jsonpath="{.clusters[?(@.name == \"kind-${CLUSTER_NAME}\")].cluster.server}")
echo "# Cluster is running, kubectl should point to the new cluster at ${CLUSTER_API_URL}"
kubectl cluster-info
