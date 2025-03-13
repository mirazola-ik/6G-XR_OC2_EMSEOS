#!/bin/bash

# local_mode=false
kubeconfig_path="/home/mirazola/emseos/emseos_backup/kubeconfig"
# kubeconfig_string = --kubeconfig $kubeconfig_path  OR empty string if running in local mode
# Check if the kubeconfig file exists
if [ -f "$kubeconfig_path" ]; then
  kubeconfig_string="--kubeconfig $kubeconfig_path"
else
  kubeconfig_string=" " # running in local, no kubeconfig usage
fi
echo $kubeconfig_string

cd scripts/
./setup_add_helm_repos.sh 


kubectl  $kubeconfig_string create namespace ikerlan-monitoring


# Create & label configmaps
cd ../src/prometheusStack/dashboards

# Scaphandre dashboard  - Enable optionally
# kubectl  $kubeconfig_string create configmap scaphandre-dashboard --from-file=scaphandre_dashboard.json -n ikerlan-monitoring  --dry-run=client -o yaml | kubectl  $kubeconfig_string apply -f -
# kubectl  $kubeconfig_string label configmap scaphandre-dashboard grafana_dashboard=1 -n ikerlan-monitoring --overwrite

# DCGM dashboard - Enable optionally
# kubectl  $kubeconfig_string create configmap dcgm-dashboard --from-file=dcgm_dashboard.json -n ikerlan-monitoring  --dry-run=client -o yaml | kubectl  $kubeconfig_string apply -f -
# kubectl  $kubeconfig_string label configmap dcgm-dashboard grafana_dashboard=1 -n ikerlan-monitoring --overwrite

# K8S Cluster dashboard
kubectl  $kubeconfig_string create configmap k8s-cluster-dashboard --from-file=k8s_cluster_dashboard.json -n ikerlan-monitoring  --dry-run=client -o yaml | kubectl  $kubeconfig_string apply -f -
kubectl  $kubeconfig_string label configmap k8s-cluster-dashboard grafana_dashboard=1 -n ikerlan-monitoring --overwrite

# Energy dashboard (both GPU and CPU)
kubectl  $kubeconfig_string create configmap emseos-energy-dashboard-v1 --from-file=emseos_energy_dashboard_v1.json -n ikerlan-monitoring  --dry-run=client -o yaml | kubectl  $kubeconfig_string apply -f -
kubectl  $kubeconfig_string label configmap emseos-energy-dashboard-v1 grafana_dashboard=1 -n ikerlan-monitoring --overwrite

# Deploy prometheus stack using Helm
cd ../helm
helm install $kubeconfig_string prometheus prometheus-community/kube-prometheus-stack --namespace ikerlan-monitoring --values values_prometheusStack.yml

# Install nvidia device plugin
cd ../../dcgm/helm
kubectl  $kubeconfig_string  apply -f nvidia-device-plugin.yml

# Install DCGM
helm install $kubeconfig_string dcgm gpu-helm-charts/dcgm-exporter --namespace ikerlan-monitoring --values values_dcgm.yaml

# Install Scaphandre
cd ../../scaphandre
helm install $kubeconfig_string scaphandre scaphandre_repo/helm/scaphandre --namespace ikerlan-monitoring --values helm/values_scaphandre.yaml


