#!/usr/bin/env bash
# Add the nvidia-device-plugin helm repository:
helm repo add nvdp https://nvidia.github.io/k8s-device-plugin

# Add NVIDIA DCGM exporter
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts

# Add Prometheus Community repo (for Prometheus)
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Add Grafana repo (for Grafana)
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update
