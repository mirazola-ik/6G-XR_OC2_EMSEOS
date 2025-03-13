# Overview
This document serves as a guide for the implementation process of the monitoring system.

> WARNING
> In case a remote cluster is targeted, the *`--kubeconfig`* flag must be used in every kubectl and helm commands:
> - `kubectl --kubeconfig=kubeconfig get nodes`
> - `helm install prometheus prometheus-community/kube-prometheus-stack --kubeconfig kubeconfig --namespace ikerlan-monitoring --values values.yml` 
---

# Implementation
## 0- Helm: install necessary charts
```bash
sudo ./scripts/setup_add_helm_repos.sh
```

## 1- Create namespace *ikerlan-monitoring*
Check existing namespaces:
```bash
$ kubectl get namespaces
NAME              STATUS   AGE
default           Active   47d
kube-node-lease   Active   47d
kube-public       Active   47d
kube-system       Active   47d
metallb-system    Active   25d
```

```bash
$ kubectl create namespace ikerlan-monitoring
```

Verify:
```bash
$ kubectl get namespaces
NAME                 STATUS   AGE
default              Active   47d
ikerlan-monitoring   Active   2s
kube-node-lease      Active   47d
kube-public          Active   47d
kube-system          Active   47d
metallb-system       Active   25d
```

## 2- Create Grafana configmaps to dashboards appear in the UI
Create the configmaps, using the dashboard JSON files:
```bash
kubectl create configmap scaphandre-dashboard \
  --from-file=scaphandre_dashboard.json \
  -n ikerlan-monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create configmap dcgm-dashboard \
  --from-file=dcgm_dashboard.json \
  -n ikerlan-monitoring \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create configmap k8s-cluster-dashboard \
  --from-file=k8s_cluster_dashboard.json \
  -n ikerlan-monitoring \
  --dry-run=client -o yaml | kubectl apply -f -
```

Then, label them, so that the Grafana sidecar located inside *values_prometheusStack.yml* automatically detects them:
```bash
kubectl label configmap scaphandre-dashboard grafana_dashboard=1 -n ikerlan-monitoring --overwrite

kubectl label configmap dcgm-dashboard grafana_dashboard=1 -n ikerlan-monitoring --overwrite

kubectl label configmap k8s-cluster-dashboard grafana_dashboard=1 -n ikerlan-monitoring --overwrite
```


## 3- Deploy prometheus stack using Helm
As DCGM-exporter needs prometheus, it is installed before DCGM-exporter. Additionally, grafana is also installed during this step, as it is included in the *prometheus-community/kube-prometheus-stack* helm chart.

```bash
$ helm install prometheus prometheus-community/kube-prometheus-stack --kubeconfig kubeconfig --namespace ikerlan-monitoring --values prometheus/values_prometheusStack.yml
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: kubeconfig
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: kubeconfig

NAME: prometheus
LAST DEPLOYED: Mon Jan 13 10:14:50 2025
NAMESPACE: ikerlan-monitoring
STATUS: deployed
REVISION: 1
NOTES:
kube-prometheus-stack has been installed. Check its status by running:
  kubectl --namespace ikerlan-monitoring get pods -l "release=prometheus"

Visit https://github.com/prometheus-operator/kube-prometheus for instructions on how to create & configure Alertmanager and Prometheus instances using the Operator.
```

Verify prometheus stack installation:
```bash
$ kubectl get pods -n ikerlan-monitoring
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          42s
prometheus-grafana-8595fbfd55-7944z                      3/3     Running   0          59s
prometheus-kube-prometheus-operator-cc6fd6bb8-6dvr7      1/1     Running   0          59s
prometheus-kube-state-metrics-675db84765-7z8m9           1/1     Running   0          59s
prometheus-prometheus-kube-prometheus-prometheus-0       1/2     Running   0          42s
prometheus-prometheus-node-exporter-hh9sr                1/1     Running   0          59s
```

## 4- Install NVIDIA device plugin (prerequisite for DCGM)
It must be installed in ***kube-system*** namespace.

```bash
$ kubectl  apply -f mia-deployment/helm_charts/nvidia-device-plugin.yml
daemonset.apps/nvidia-device-plugin-daemonset created
```

## 5- Deploy NVIDIA DCGM tool
> WARNING
> Take into account that if dcgm-exporter image is not present in the cluster, the first time takes about ~5 minutes to set up as it has to pull the image from the internet.
```bash
$ helm install dcgm gpu-helm-charts/dcgm-exporter --kubeconfig kubeconfig --namespace ikerlan-monitoring --values mia-deployment/helm_charts/values_dcgm.yaml
WARNING: Kubernetes configuration file is group-readable. This is insecure. Location: kubeconfig
WARNING: Kubernetes configuration file is world-readable. This is insecure. Location: kubeconfig
NAME: dcgm
LAST DEPLOYED: Mon Jan 13 10:22:49 2025
NAMESPACE: ikerlan-monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods -n ikerlan-monitoring -l "app.kubernetes.io/name=dcgm-exporter,app.kubernetes.io/instance=dcgm" -o jsonpath="{.items[0].metadata.name}")
  kubectl -n ikerlan-monitoring port-forward $POD_NAME 8080:9400 &
  echo "Visit http://127.0.0.1:8080/metrics to use your application"
```

Verify DCGM installation (dcgm pod should appear as running):
```bash
$ kubectl get pod -n ikerlan-monitoring | grep "dcgm"
```


## 6- Deploy scaphandre tool
```bash
helm install scaphandre mia-deployment/local_files/scaphandre/helm/scaphandre --kubeconfig kubeconfig --namespace ikerlan-monitoring --values mia-deployment/helm_charts/values_scaphandre.yaml
```
