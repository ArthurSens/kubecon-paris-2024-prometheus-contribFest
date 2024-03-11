# Prometheus Operators Contribfest Workshop

Intro text WIP

## Prepare your workspace

You'll need go, docker, kind and kubectl installed. Once you get there simply
run:

```sh 
bash prepare.sh
```

## Bootstrapping the scenario
### Start the Prometheus Receiver
Start the Prometheus Receiver. It will be used to receive write requests in both the `prometheus-operator` and `gmp-operator` scenarios.

<b>Start the Prometheus receiver</b>: Run the following commands: 

```sh 
kubectl create namespace prometheus
kubectl apply -f prometheus-receiver/prometheus-receiver.yaml -n prometheus
```
<b>Verify Prometheus Receiver is running</b>: 
- Run the following command:
    ```sh
    kubectl -n prometheus port-forward  deployment/prometheus-receiver  9090
    ```
- <b>Access the UI:</b> Confirm the Prometheus UI is accessible in your web browser at http://localhost:9090. Leave the terminal and browser open.