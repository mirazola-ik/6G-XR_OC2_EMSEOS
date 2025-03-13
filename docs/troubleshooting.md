# Overview
This document presents the troubleshooting steps for common implementation issues

# A) DCGM implementation issues
## No DCGM pod running after helm installation, but daemonset is running
Verify what DCGM resources are running:
```bash
$ kubectl get all -n ikerlan-monitoring | grep dcgm
service/dcgm-dcgm-exporter    11m   app.kubernetes.io/instance=dcgm,app.kubernetes.io/name=dcgm-exporter
daemonset.apps/dcgm-dcgm-exporter    11m   exporter        nvcr.io/nvidia/k8s/dcgm-exporter:3.3.9-3.6.1-ubuntu22.04   app.kubernetes.io/component=dcgm-exporter,app.kubernetes.io/instance=dcgm,app.kubernetes.io/name=dcgm-exporter
```

From the previous output, we see that daemonset is running, but no pods have been created, so check for events or error messages in the dcgm-exporter DaemonSet:
```bash
$ kubectl describe daemonset dcgm-dcgm-exporter -n ikerlan-monitoring
```

Look for warnings or errors related to:
- Node selector or tolerations preventing pod scheduling.
- Image pull errors.

Follow the following steps to troubleshoot:
1. Check node eligibility
  - Ensure that your cluster nodes meet the requirements for running the dcgm-exporter:
     - Nodes should have NVIDIA GPUs.
     - The NVIDIA device drivers and nvidia-container-runtime should be properly installed on each node.
  - 
    ```bash
      kubectl get nodes -o wide
      kubectl describe node <node-name> | grep -i gpu
    ```

2. Check node resources
```bash
$ kubectl describe node k8s-master | grep -i nvidia
```

If no output is returned, label the node accordingly:
```bash
$ kubectl label node k8s-master nvidia.com/gpu.present=true

```

3. Check runtimeclass
If in the daemonset description you see the following error:
```bash
kubectl describe daemonset dcgm-dcgm-exporter -n ikerlan-monitoring
          ...
Events:
  Type      Reason        Age                From                  Message
  ----      ------        ----               ----                  -------
  Warning   FailedCreate  7s (x14 over 48s)  daemonset-controller  Error creating: pods "dcgm-dcgm-exporter-" is forbidden: pod rejected: RuntimeClass "nvidia" not found
```

Means that the runtime class needed for DCGM is not found. So install the NVIDIA container runtime and set it upas a RuntimeClass:
```bash
$ kubectl get runtimeclass
No resources found

$ kubectl  apply -f mia-deployment/helm_charts/nvidia-runtimeclass.yaml
runtimeclass.node.k8s.io/nvidia created

$ kubectl get runtimeclass
NAME     HANDLER   AGE
nvidia   nvidia    3s
```

And reinstall the helm dcgm chart again:
```bash
$ helm uninstall dcgm --kubeconfig kubeconfig -n ikerlan-monitoring
release "dcgm" uninstalled

$ helm install dcgm gpu-helm-charts/dcgm-exporter --kubeconfig kubeconfig --namespace ikerlan-monitoring --values mia-deployment/helm_charts/values_dcgm.yaml
```

Verify if the daemonset creates the pod:
```bash
kubectl describe daemonset dcgm-dcgm-exporter -n ikerlan-monitoring
          ...
Events:
  Type    Reason            Age   From                  Message
  ----    ------            ----  ----                  -------
  Normal  SuccessfulCreate  13s   daemonset-controller  Created pod: dcgm-dcgm-exporter-gkk2b
```

Finally, check if the DCGM pod is created:
```bash
kubectl get all -n ikerlan-monitoring | grep dcgm
pod/dcgm-dcgm-exporter-gkk2b                                 0/1     ContainerCreating   0          6m32s
service/dcgm-dcgm-exporter                        ClusterIP      10.100.198.200   <none>        9400/TCP                        6m32s
daemonset.apps/dcgm-dcgm-exporter                    1         1         0       1            0           <none>                   6m32s
```