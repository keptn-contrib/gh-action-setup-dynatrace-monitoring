#!/bin/bash

source ${BASE_PATH}/utils.sh

echo "Deploying Dynatrace OneAgent Operator"
wget https://github.com/dynatrace/dynatrace-operator/releases/latest/download/install.sh -O install.sh && sh ./install.sh --api-url "https://${DT_TENANT}/api" --api-token "${DT_API_TOKEN}" --paas-token "${DT_PAAS_TOKEN}" --enable-k8s-monitoring --enable-volume-storage

# setup automatic tagging rules

# keptn_selfmon_service tagging rule, e.g., keptn_selfmon_service: shipyard-controller
echo "setting up tagging rule: keptn_selfmon_service"
curl -X POST \
  https://${DT_TENANT}/api/config/v1/autoTags \
  -H "Authorization: Api-token ${DT_API_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "keptn_selfmon_service",
  "rules": [
        {
            "type": "SERVICE",
            "enabled": true,
            "valueFormat": "{ProcessGroup:KubernetesContainerName}",
            "propagationTypes": [],
            "conditions": [
                {
                    "key": {
                        "attribute": "PROCESS_GROUP_PREDEFINED_METADATA",
                        "dynamicKey": "KUBERNETES_NAMESPACE",
                        "type": "PROCESS_PREDEFINED_METADATA_KEY"
                    },
                    "comparisonInfo": {
                        "type": "STRING",
                        "operator": "BEGINS_WITH",
                        "value": "'${KEPTN_SELF_MONITORING_PROJECT}'",
                        "negate": false,
                        "caseSensitive": true
                    }
                }
            ]
        }
    ]
}
'

# keptn_selfmon_namespace tagging rule, e.g., keptn_selfmon_namespace: tanus-dev
echo "setting up tagging rule: keptn_selfmon_namespace"
curl -X POST \
  https://${DT_TENANT}/api/config/v1/autoTags \
  -H "Authorization: Api-token ${DT_API_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "keptn_selfmon_namespace",
  "rules": [
        {
            "type": "SERVICE",
            "enabled": true,
            "valueFormat": "{ProcessGroup:KubernetesNamespace}",
            "propagationTypes": [],
            "conditions": [
                {
                    "key": {
                        "attribute": "PROCESS_GROUP_PREDEFINED_METADATA",
                        "dynamicKey": "KUBERNETES_NAMESPACE",
                        "type": "PROCESS_PREDEFINED_METADATA_KEY"
                    },
                    "comparisonInfo": {
                        "type": "STRING",
                        "operator": "BEGINS_WITH",
                        "value": "'${KEPTN_SELF_MONITORING_PROJECT}'",
                        "negate": false,
                        "caseSensitive": true
                    }
                }
            ]
        }
    ]
}
'

echo "creating Dynatrace secret"
kubectl create secret generic dynatrace -n "keptn" --from-literal="DT_TENANT=${DT_TENANT}" --from-literal="DT_API_TOKEN=${DT_API_TOKEN}"

echo "deploying dynatrace-service"

if [[ $DYNATRACE_SERVICE_VERSION == "0.12.0" ]]; then
  kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/dynatrace-service/release-0.12.0/deploy/service.yaml -n keptn
else
  wget "https://github.com/keptn-contrib/dynatrace-service/releases/download/${DYNATRACE_SERVICE_VERSION}/dynatrace-service-${DYNATRACE_SERVICE_VERSION}.tgz" -O "${HOME}/downloads/dynatrace-service.tgz"
  mv ${HOME}/downloads/dynatrace-service.tgz ${HOME}/uniform-dist/
  helm install dynatrace-service http://0.0.0.0:8000/"dynatrace-service.tgz" -n keptn
fi

echo "deploying dynatrace-sli-service"
if [[ $DYNATRACE_SLI_SERVICE_VERSION == "0.9.0" ]]; then
  kubectl apply -f https://raw.githubusercontent.com/keptn-contrib/dynatrace-sli-service/release-0.9.0/deploy/service.yaml -n keptn
else
  wget "https://github.com/keptn-contrib/dynatrace-sli-service/releases/download/${DYNATRACE_SLI_SERVICE_VERSION}/dynatrace-sli-service-${DYNATRACE_SLI_SERVICE_VERSION}.tgz" -O "${HOME}/downloads/dynatrace-sli-service.tgz"
  mv ${HOME}/downloads/dynatrace-sli-service.tgz ${HOME}/uniform-dist/
  helm install dynatrace-sli-service http://0.0.0.0:8000/"dynatrace-sli-service.tgz" -n keptn
fi

wait_for_deployment_in_namespace "dynatrace-service" "keptn"
wait_for_deployment_in_namespace "dynatrace-sli-service" "keptn"

echo "configuring keptn for dynatrace monitoring"
keptn configure monitoring dynatrace --project="${KEPTN_SELF_MONITORING_PROJECT}"

echo "uploading sli config to ${KEPTN_SELF_MONITORING_PROJECT}"
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/sli.yaml --resourceUri=dynatrace/sli.yaml --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/slo.yaml --resourceUri=slo.yaml --all-stages