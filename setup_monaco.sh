#!/bin/bash

source ${BASE_PATH}/utils.sh

echo "deploying monaco-service"
kubectl apply -f https://raw.githubusercontent.com/keptn-sandbox/monaco-service/${MONACO_SERVICE_VERSION}/deploy/service.yaml -n keptn

wait_for_deployment_in_namespace "monaco-service" "keptn"

# Management Zone
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/management-zone/zone.yaml --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/management-zone/zone.yaml --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/management-zone/zone.json --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/management-zone/zone.json --all-stages

# Tagging rules
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/auto-tag/tagging.yaml --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/auto-tag/tagging.yaml --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/auto-tag/keptn_selfmon_namespace.json --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/auto-tag/keptn_selfmon_namespace.json --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/auto-tag/keptn_selfmon_service.json --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/auto-tag/keptn_selfmon_service.json --all-stages

# Service Naming
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/conditional-naming/conditional-naming-service.yaml --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/conditional-naming-service/conditional-naming-service.yaml --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/conditional-naming/keptn_service.json --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/conditional-naming-service/keptn_service.json --all-stages

# Custom Metrics
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/calculated-metrics-service/calculated-metrics-service.yaml --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/calculated-metrics-service/calculated-metrics-service.yaml --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/calculated-metrics-service/fast_requests.json --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/calculated-metrics-service/fast_requests.json --all-stages

# SLOs
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/slo/slo.yaml --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/slo/slo.yaml --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/slo/performance.json --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/slo/performance.json --all-stages
keptn add-resource --project=${KEPTN_SELF_MONITORING_PROJECT} --service=keptn --resource=${BASE_PATH}/assets/monaco/slo/service_availability.json --resourceUri=dynatrace/projects/${KEPTN_SELF_MONITORING_PROJECT}/slo/service_availability.json --all-stages