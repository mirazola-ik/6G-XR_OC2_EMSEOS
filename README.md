# Overview
This repository contains the work supported by the [EMSEOS Open Call](https://6g-xr.eu/open-calls/oc2-results/) of the [6G-XR](https://6g-xr.eu/) project.
---
# Prerequisites
> INFO
> 
> In case a remote cluster is targeted, the *`--kubeconfig`* flag must be used in every kubectl and helm commands:
> - `kubectl --kubeconfig=kubeconfig get nodes`
> - `helm install prometheus prometheus-community/kube-prometheus-stack --kubeconfig kubeconfig --namespace ikerlan-monitoring --values values.yml` 
## Working directory structure:
- Ensure access to a running Kubernetes cluster.
- *kubeconfig* file in root folder (./)
- Files under *scripts* folder need to be executable: 
  ```bash
  chmod +x scripts/*
  ```
- File setup.sh, located in the root project directory, needs to be executable:
  ```bash
  chmod +x setup.sh
  ```

## Helm and Kubectl install
Execute the following to install both Kubectl & helm:
```bash
sudo ./scripts/preinstall_tools.sh
```

# Implementation
For an automated deployment, execute [setup.sh](setup.sh) script, make sure to make it executable beforehand.

Otherwise, if manual implementation is preferred, [an implementation guide](docs/implementation.md) can be found inside the *docs* folder, which also explains the commands used in each step of the automated deployment script.

# Troubleshooting
[A troubleshooting document](docs/troubleshooting.md) for most common problems during implementation can be found in the *docs* folder

# Port information
Below there are described the necessary ports to be enabled in the project.

### Prometheus
Prometheus is configured as a NodePort, and will be accesible in port 30090.

### Grafana
Grafana is configured as a NodePort, and will be accesible in port 31090.
- Default user: "admin"
- Default password: "emseos"

### Cluster access port
In order to access the cluster using the provided kubeconfig file, port 6443 must be enabled.