#!/bin/bash
set -eufo pipefail
export SHELLOPTS	# propagate set to children by default

IFS=$'\t\n'

KIND_CONFIG_FILE='scripts/kind-config.yml'
CLUSTER_NAME=kubecon2024-prometheus

printf "#: Checking if all Kubernetes dependencies are installed...\n"
command -v docker >/dev/null 2>&1 || { echo 'Please install docker (docker + https://github.com/abiosoft/colima on MacOS works well if Docker Desktop license does not work for you'; exit 1; }
command -v go >/dev/null 2>&1 || { echo 'Please install go (https://go.dev/doc/install)'; exit 1; }
command -v kind >/dev/null 2>&1 || { bash ./scripts/install-kind.sh; }
command -v kubectl >/dev/null 2>&1 || { echo 'Please install kubectl (https://kubernetes.io/docs/tasks/tools/#kubectl)'; exit 1; }
printf "All dependencies installed!\n"

# Do nothing if cluster already exists
if kind get clusters | grep -q "^${CLUSTER_NAME}$"
then
  printf "WARN: Cluster %s already exists, skipping creation\n" "${CLUSTER_NAME}"
  exit 0
fi

# If you need to debug the kind creation command add the following to it
# --verbosity 2147483647 \
kind create cluster \
  --name ${CLUSTER_NAME} \
  --image kindest/node:v1.29.2 \
  --config "$KIND_CONFIG_FILE" \
  --wait 30s \
  --retain

CLUSTER_API_URL=$(kubectl config view --minify -o jsonpath="{.clusters[?(@.name == \"kind-${CLUSTER_NAME}\")].cluster.server}")
printf "## Cluster is now running, kubectl should point to the new cluster at %s\n" "${CLUSTER_API_URL}"
kubectl cluster-info

printf "## Installing metrics-server\n"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.7.0/components.yaml

kubectl patch -n kube-system deployment metrics-server --type=json \
  -p '[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'

printf "## Instaling General Requirements\n"
kubectl apply -f scenarios/0_initial

printf "## Instaling Prometheus Operator Requirements\n"
kubectl apply -f scenarios/prometheus-operator/requirements --server-side

printf "## Waiting until all services are ready\n"
kubectl wait --for=condition=ready pod -n remote -l app=metric-backend -l app=prometheus --timeout=10m
kubectl wait --for=condition=ready pod -n monitoring -l app=prometheus --timeout=10m
kubectl wait --for=condition=ready pod -n default -l app=metric-source --timeout=10m

exit 0
