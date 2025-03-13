#!/bin/bash

# 1- [LOCAL] Install kubectl
# Considering SNAP is supported. Otherwise refer to: https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/
snap install kubectl --classic
kubectl version --client

# 2- [LOCAL] Install Helm
if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."

    # Download and install Helm
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh
    ./get_helm.sh

    echo "Helm installed correctly"
else
    echo "Helm already installed."
fi