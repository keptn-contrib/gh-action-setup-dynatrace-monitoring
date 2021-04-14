#!/bin/bash

kubectl get namespaces # TODO remove, only for testing purposes
#wget https://github.com/dynatrace/dynatrace-operator/releases/latest/download/install.sh -O install.sh && sh ./install.sh --api-url "${DT_TENANT}" --api-token "${DT_API_TOKEN}" --paas-token "${DT_PAAS_TOKEN}" --enable-k8s-monitoring --enable-volume-storage