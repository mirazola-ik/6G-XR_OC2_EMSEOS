# Overview
- This document describes the modifications done in the Scaphandre repository.
- Note that the modificitations described in this document are **already implemented** in the current repository.

# Important notes
- The EMSEOS Scaphandre implementation was done using the ***dev*** Scaphandre branch as base.
- Additionally, some modifications were done to the files of the dev branch, which are explained below.
- In "*scaphandre/helm/scaphandre/templates/daemon.yml*", set ***privilege: true***. Otherwise Scaphandre doesn't run.

# Modifications
## 1. Modified Scaphandre source code
As reported in the [Scaphandre's repository issues page](https://github.com/hubblo-org/scaphandre/issues/347), there is a modification to be done in the code to be able to detect containers correctly. Due to this, the original docker image used by the authors could not be used. A new docker image ([mirazola/scaphandre-test:latest](https://hub.docker.com/r/mirazola/scaphandre-test)) was built using the [Dockerfile](./scaphandre/Dockerfile) located in this repository.


## 2. Created custom Docker image
- mirazola/scaphandre-test:latest

## 3. Modified YAML files
> Note: These files are located inside *scaphandre/helm
/scaphandre/* directory.

### 3.1 values.yaml
- It uses the YAML file uses the custom Docker image created before ("mirazola/scaphandre-test:latest").
- Modify the format of "scaphandre:" key to use "*--containers*" argument.

### 3.2 templates/daemonset.yaml
- Modify format to match *values.yaml* change related to "*--containers*" argument.
- Add *privileged* keyword to enable containers access host RAPL directories ("*/proc*" and "*/sys/class/powercap*").
  - ```bash
    securityContext:
        privileged
    ```
### 3.3 templates/servicemonitor.yaml
ScrapeTimeout needs to be smaller thatn ScrapeInterval. As we have set ScrapeInterval to 3s (default is 1m) we need to modify ScrapeTimeout accordingly.
```bash
~/mirazola$ grep -r "scrapeTimeout" scaphandre/
    scaphandre/helm/scaphandre/templates/servicemonitor.yaml:      scrapeTimeout: 30s

~/mirazola$ nano scaphandre/helm/scaphandre/templates/servicemonitor.yaml

~/mirazola$ grep -r "scrapeTimeout" scaphandre/
    scaphandre/helm/scaphandre/templates/servicemonitor.yaml:      scrapeTimeout: 2s
```