#!/bin/bash

wget https://github.com/dynatrace/dynatrace-operator/releases/latest/download/install.sh -O install.sh && sh ./install.sh --api-url "${DT_TENANT}" --api-token "${DT_API_TOKEN}" --paas-token "${DT_PAAS_TOKEN}" --enable-k8s-monitoring --enable-volume-storage

# setup automatic tagging rules

# keptn_selfmon_service tagging rule, e.g., keptn_selfmon_service: shipyard-controller

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
                        "value": "'${KEPTN__SELF_MONITORING_PROJECT}'",
                        "negate": false,
                        "caseSensitive": true
                    }
                }
            ]
        }
    ]
}
'

# keptn_selfmon_stage tagging rule, e.g., keptn_selfmon_stage: tanus-dev
curl -X POST \
  https://${DT_TENANT}/api/config/v1/autoTags \
  -H "Authorization: Api-token ${DT_API_TOKEN}" \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "keptn_selfmon_stage",
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
                        "value": "'${KEPTN__SELF_MONITORING_PROJECT}'",
                        "negate": false,
                        "caseSensitive": true
                    }
                }
            ]
        }
    ]
}
'