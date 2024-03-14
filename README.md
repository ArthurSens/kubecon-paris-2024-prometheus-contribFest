# kubecon-paris-2024-prometheus-contribFest

Repository with scripts, slides and guidance for Prometheus ContribFest in KubeCon Paris 2024

Slides: https://docs.google.com/presentation/d/1ERc2DJZBIp6UcL_vtAQocBjbiSxgMw009fzZBsUa3j0/edit

## Workshop Setup

### Start your cluster

You'll need `go`, `docker`, `kind` and `kubectl` installed. Once you get there simply
run:

```sh 
bash cluster_create.sh
```

This will create a 3-node workshop cluster called `kubecon2024-prometheus` and connect `kubectl` to that cluster.

### Initial Stage (Stage 0)

In the initial step we expect:

* Metric source pods (avalanche) in the `default` namespace running.

  ```bash
  kubectl apply -f scenarios/0_initial/metric-source.yaml
  ```

* Metric backend pod (Prometheus that receives remote-write and exposes UI) in the `remote` namespace running.

  ```bash
  kubectl apply -n remote -f scenarios/0_initial/metric-remote-backend.yaml
  ```

  Verify Prometheus Receiver is running:
  
  ```bash
  kubectl -n remote port-forward  deployment/prometheus-receiver 9090
  ```
  
  Confirm the Prometheus UI is accessible in your web browser at http://localhost:9090.

* Metric collection... (TODO: Setup two Prometheus replicas in hashmod manually for users? How to do scale limit?)

#### Stress Scenario

1. Verify

TODO: Tell user how to verify expected metric in the remote backend (alert, link to query? both?)

2. Scale

TODO: Scale replicas?

3. Verify
   
TODO: See not all is monitored?

### Stage 1A: Prometheus Operator Stage

TODO

Do the [Stress Scenario](#stress-scenario)

### Stage 1B: GMP Operator Stage

GMP operator allows you to globally monitor and alert on your workloads using Prometheus,
all without the hassle of manually managing and operating Prometheus instances. GMP operator automatically scales to handle your data.

TODO Ask user to deploy on their own just give basic hints? Tell them what to do without providing yamls?

Do the [Stress Scenario](#stress-scenario)

