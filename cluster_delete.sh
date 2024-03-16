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

if kind get clusters | grep -q "^${CLUSTER_NAME}$"
then
  kind delete cluster -n ${CLUSTER_NAME}
fi
echo "# Cluster ${CLUSTER_NAME} is not running"
