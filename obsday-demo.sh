#!/usr/bin/env bash

# Example on how to use it https://github.com/bwplotka/demo-nav/blob/master/example/demo-example.sh

NUMS=false
#IMMEDIATE_REVEAL=true

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
. "${DIR}/demo-nav.sh"

# Yolo aliases
function cat() {
    bat -p --color=always "$@"
}

clear

p "# Let's start metric source (avalanche)"
r "kubectl apply -f scenarios/0_initial/metric-source.yaml"

p "# Let's start remote backend (receiving Prometheus in remote ns)"
r "kubectl apply -n remote -f scenarios/0_initial/metric-backend.yaml"
r "kubectl port-forward -n remote svc/metric-backend 9090"

p "# Let's install Prometheus Operator"
r "kubectl -n prom-op-system create -f scenarios/prometheus-operator/.reference/bundle.yaml"
r "cat scenarios/prometheus-operator/.reference/prometheus.yaml"
r "kubectl -n prom-op-system apply -f scenarios/prometheus-operator/.reference/prometheus.yaml"
r "kubectl -n prom-op-system get po"

r "cat scenarios/prometheus-operator/.reference/pod-monitor.yaml"
r "kubectl apply -f scenarios/prometheus-operator/.reference/pod-monitor.yaml"
r "kubectl port-forward -n remote svc/metric-backend 9090"

p "# Let's install GMP Operator"
r "kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/main/manifests/setup.yaml"
r "kubectl apply -f scenarios/gmp-operator/.reference/operator.yaml"

p "# Configure operator & apply it"
r "cat scenarios/gmp-operator/.reference/config.yaml"
r "kubectl apply -n gmp-public -f scenarios/gmp-operator/.reference/config.yaml"
r "kubectl -n gmp-system get po"

p "# Let's look on PodMonitoring & apply it"
r "cat scenarios/gmp-operator/.reference/metric-source-podmonitoring.yaml"
r "kubectl apply -f scenarios/gmp-operator/.reference/metric-source-podmonitoring.yaml"
r "kubectl apply -n gmp-system -f scenarios/gmp-operator/.reference/self-podmonitoring.yaml"
r "kubectl port-forward -n remote svc/metric-backend 9090"

r "That's it, thanks!" "echo '🤙🏽'"

navigate true
