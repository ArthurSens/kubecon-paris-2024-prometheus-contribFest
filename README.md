# kubecon-paris-2024-prometheus-contribFest

Repository with scripts, slides and guidance for Prometheus ContribFest in KubeCon Paris 2024

Slides: https://docs.google.com/presentation/d/1ERc2DJZBIp6UcL_vtAQocBjbiSxgMw009fzZBsUa3j0/edit

## Workshop Setup

> NOTE: If you have any problem with any scenario, check reference configuration [Prometheus Operator](scenarios/prometheus-operator/.reference), [GMP Operator](scenarios/gmp-operator/.reference) made by us (don't cheat!) (:

### Initial Stage

You'll need `go`, `docker`, `kind` and `kubectl` installed. Once you get there simply
run:

```sh 
make cluster-create
```

This will create a 3-node workshop cluster called `kubecon2024-prometheus` and connect `kubectl` to that cluster.

This will also run initial scenario (`kubectl apply -f scenarios/0_initial`):

* Metric source pods (avalanche) in the `default` namespace running (10 replicas)
* 2 Prometheus hashmod without operator in `monitoring` namespace scraping metric source pods
* Metric backend pod (Prometheus that receives remote-write and exposes UI) in the `remote` namespace running.
  * NOTE: Remote write endpoint will be available in the cluster under `http://metric-backend.remote.svc:9090/api/v1/write` URL.

You can verify Prometheus Receiver is running and have metric source metrics:
  
  ```bash
  kubectl -n remote port-forward svc/metric-backend 9090
  ```
  
  Confirm the Prometheus UI is accessible in your web browser at http://localhost:9090.

### Stress Scenario

Here we can simulate running more applications, so more metrics needed to be collected in
the cluster. We won't break collection/OOM Prometheus with only 10 to 15 replica
increase, but imagine this won't fit in 2 Prometheus replicas you might have.

With initial collector, you would need to manually change configuration when the
more applications are scheduled to the cluster.

1. Verify

First let's make sure you have 10 replicas visible on remote backend UI, so
   
  ```bash
  kubectl -n remote port-forward svc/metric-backend 9090
  ```

Query for e.g. `sum(up) by (instance, pod, operator)` on http://localhost:9090.

2. Scale

Scale replicas to 15 e.g. `kubectl scale deployment/metric-source --replicas=15 `

3. Verify

Forward traffic again to remote backend:

  ```bash
  kubectl -n remote port-forward svc/metric-backend 9090
  ```

Query for e.g. `sum(up) by (instance, pod, operator)` on http://localhost:9090.

### Stage 1A: Prometheus Operator Stage

Before you start (especially if you ran GMP Operator stage already):

* (opt) Ensure no `monitorig` namespace `kubectl delete namespace monitoring`
* (opt) Ensure no `gmp-system` and `gmp-public` namespace `kubectl delete namespace gmp-system` and `kubectl delete namespace gmp-public`
* Scale back (if you need) to 10 replicas `kubectl scale deployment/metric-source --replicas=10`

From high level, to run Prometheus Operator in auto-scaling hashmod mode you
need a few things:

* You need Prometheus Operator bundle (which includes CRDs, RBAC, Service Accounts and operator). 
Normally you would go to https://prometheus-operator.dev/docs/user-guides/getting-started/ website
and follow the first step. However, we provide one for you in this repo, which includes
additional component called [KEDA](https://keda.sh/) for the horizontal pod autoscaling.
It also setups Prometheus Operator in `prometheus-op-system` namespace.

  ```bash
  kubectl apply -f scenario/prometheus-operator/requirements/bundle.yaml
  ```

* Create and apply [`PrometheusAgent` Custom Resource](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1alpha1.PrometheusAgent) with remote
write configuration. Remember about podMonitorSelector options!
* Create and apply [`PodMonitor` Custom Resource](https://prometheus-operator.dev/docs/operator/api/#monitoring.coreos.com/v1.PodMonitor) to get Prometheus managed by
Prometheus Operator to scrape `metric-source` pods in the `default` namespace.
* Autoscaling configuration, so `ScaledObject` Custom Resource from KEDA e.g. on number of targets.

Once that done and working you should see avalanche metrics from Prometheus Operator
collected by remote backend:

  ```bash
  kubectl -n remote port-forward svc/metric-backend 9090
  ```

Confirm the Prometheus UI is accessible in your web browser at http://localhost:9090

Do the [Stress Scenario](#stress-scenario) to check if it auto-scales!

### Stage 1B: GMP Operator Stage

Before you start (if you ran Prometheus Operator stage already):

* (opt) Ensure no `prometheus-op-system` namespace `kubectl delete namespace prometheus-op-system`
* Scale back (if you need) to 10 replicas `kubectl scale deployment/metric-source --replicas=10`

GMP operator allows you to globally monitor and alert on your workloads using Prometheus,
all without the hassle of manually managing and operating Prometheus instances. GMP operator automatically scales to handle your data.

From high level, to run GMP operator you need a few things:

* Install the GMP Custom Resource Definitions

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/main/manifests/setup.yaml
   ```

* Install the GMP operator

   ```bash
   kubectl apply -f scenarios/gmp-operator/.reference/operator.yaml
   ```
   
   > For this contribFest we're using the latest image of gmp-operator, which is not released yet. Usually you would apply https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/main/manifests/operator.yaml

   Confirm pods have `running` status.

   ```bash
   kubectl get pods -n gmp-system
   ```

* On you own try creating [`OperatorConfig` Custom Resource](https://github.com/GoogleCloudPlatform/prometheus-engine/blob/main/doc/api.md#monitoring.googleapis.com/v1.OperatorConfig) that
configures remote write. Make sure it lands in `gmp-public` namespace (required).
* Create [`PodMonitoring` Custom Resource](https://github.com/GoogleCloudPlatform/prometheus-engine/blob/main/doc/api.md#monitoring.googleapis.com/v1.PodMonitoring) that scrapes avalanche.

Once that done and working you should see avalanche metrics from GMP Operator
collected by remote backend:

  ```bash
  kubectl -n remote port-forward svc/metric-backend 9090
  ```

Query for e.g. `sum(up) by (instance, pod, operator)` on http://localhost:9090.

You should see all avalanche metrics and you see 3 Prometheus collectors.

We don't need to stress... as we can't automatically add/remove nodes on kind, but GMP operator
would ensure Prometheus collection scales with number of nodes.


