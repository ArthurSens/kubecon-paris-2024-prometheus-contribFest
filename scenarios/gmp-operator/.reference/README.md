Reference guide, check it only if you are completely stuck or what to verify things.


## Installing GMP
1. <b>Install the GMP CRDs(Custom Resource Definitions)</b>:

   ```bash
   kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/prometheus-engine/main/manifests/setup.yaml
   ```

2. <b>Install the GMP operator</b>:

   ```bash
   kubectl apply -f scenarios/gmp-operator/.reference/operator.yaml
   ```

3. <b>Verify installation</b>: confirm pods have `running` status.

   ```bash
   kubectl get pods -n gmp-system
   ```

## Configuring Metric Collection and Export

### Set up Scraping with PodMonitoring:
1. <b>Apply a PodMonitoring</b>: PodMonitoring's tell the Prometheus collectors what to scrape.

   ```bash
   kubectl apply -n gmp-system -f scenarios/gmp-operator/.reference/metric-source-podmonitoring.yaml
   ```

3. <b>Verify Configuration:</b> Check the Prometheus config file to confirm job exists.

   ```bash
   kubectl get configmaps -n gmp-system collector -o yaml
   ```

### Enable Remote Write:

1. <b>Edit the Operator Config:</b>

   ```bash
      kubectl apply -n gmp-public -f scenarios/gmp-operator/.reference/config.yaml
   ```

4. <b>Verify your metrics:</b>
```bash
   kubectl port-forward -n remote svc/metric-backend 9090
```
- Confirm that metrics collected by GMP are visible. Should have the label `operator` set to `gmp`


