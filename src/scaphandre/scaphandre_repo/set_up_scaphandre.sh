#!/bin/bash

values_file=scaphandre/helm/scaphandre/values.yaml
values_env_file=scaphandre/helm/scaphandre/values_with_env.yaml

# Sustitución de las variables en values.yaml
if [ ! -f "$values_file" ]; then
  echo "El archivo $values_file no existe."
  exit 1
fi

envsubst < "$values_file" > "$values_env_file"


# TODO: verificar RAPL, else exit 0


# Verificar si ya existe un despliegue de Helm llamado "scaphandre"
if helm status scaphandre -n ${SCAPHANDRE_NAMESPACE} >/dev/null 2>&1; then
    echo "El despliegue de Helm 'scaphandre' ya existe."
else
    echo "El despliegue de Helm 'scaphandre' no existe. Realizando la instalación..."

    # Verificar si el archivo values.yml existe
    if [ ! -f "$values_env_file" ]; then
        echo "El archivo $values_env_file no existe."
        exit 1
    fi

    # Instalar el despliegue de Helm "scaphandre" con valores personalizados desde values.yaml
    helm uninstall scaphandre
    helm install scaphandre scaphandre/helm/scaphandre --values "$values_env_file"

    echo "El despliegue de Helm 'scaphandre' se ha instalado con éxito."
fi
