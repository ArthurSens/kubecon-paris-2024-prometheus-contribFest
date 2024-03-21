Deploy CRDs to prometheus-op-system

```
kubectl -n prometheus-op-system create -f scenarios/prometheus-operator/.reference/bundle.yaml
```

# Prometheus-Operator Scenario

## Installing Prometheus-Operator

1. <b>Install the Prometheus-Operator CRDs(Custom Resource Definitions)</b>:

```bash
kubectl apply -f bundle.yaml
```

2. <b>Verify installation</b>: confirm the Prometheus-Operator pod have `running` status.

```bash
kubectl get pods -n prometheus-operator
```

## Stress scenario

> TODO

## Vanilla HPA

> TODO

## Keda autoscaler

1. <b>Add Helm repo</b>:

```bash
helm repo add kedacore https://kedacore.github.io/charts
helm repo update
```

2. <b>Install keda Helm chart</b>:

```bash
helm install keda kedacore/keda --namespace keda --create-namespace
```

3. <b>Verify installation</b>: confirm the Keda-Operator pods have `running` status.

```bash
kubectl get pods -n keda
```