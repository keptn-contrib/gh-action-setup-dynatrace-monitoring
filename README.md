# gh-action-setup-dynatrace-monitoring

GH Action to set up Dynatrace monitoring on an existing Keptn cluster. This action will deploy the Dynatrace OneAgent, and install the dynatrace-service, as well as the dynatrace-sli-service.
It will also add SLI/SLO configs that can be used to evaluate the performance of the monitored keptn instance.

## Parameters
| Name | Mandatory | Format | Description | Default |
|--|--|--|--|--|
| DTTenant | yes | string | Dynatrace Tenant | - |
| DTAPIToken | yes | string | Dynatrace API Token| - |
| DTPaaSToken | yes | string | Dynatrace PaaS Token | - |
| KeptnSelfMonitoringProject | no | string | Name of the Keptn selfmonitoring project | `keptn` |
| DynatraceServiceVersion | no | string | Version of the dynatrace-service | `0.13.0` |
| DynatraceSLIServiceVersion | no | string | Version of the dynatrace-sli-service | `0.10.0` |


## Example usage

```yaml
# This is a basic workflow to help you get started with Actions

name: CI

# Controls when the action will run. 
on:
  workflow_dispatch:

jobs:
  setup_keptn:
    runs-on: ubuntu-latest
    name: Setup Keptn
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Setup Keptn
        id: setup-keptn
        uses: keptn/gh-action-setup-keptn@main
        with:
          KeptnVersion: '0.8.1'
          GKEClusterVersion: '1.18'
          GKEProjectName: ${{ secrets.GKE_PROJECT_NAME }}
          GCloudServiceKey: ${{ secrets.GCLOUD_SERVICE_KEY }}
          GKEClusterName: 'keptn-meta-test'

      - name: Setup DT Monitoring
        id: setup-dt-monitoring
        uses: keptn-contrib/gh-action-setup-dynatrace-monitoring@implement-action
        with:
          DTTenant: ${{ secrets.DT_TENANT }}
          DTAPIToken: ${{ secrets.DT_API_TOKEN }}
          DTPaasToken: ${{ secrets.DT_PAAS_TOKEN }}

      - name: Update shipyard to include evaluation in hardening
        id: update-shipyard
        run: |
          keptn add-resource --project=keptn --resource=./assets/shipyard.yaml --resourceUri=shipyard.yaml
          keptn add-resource --project=keptn --service=keptn --stage=hardening --resource=./assets/load.jmx --resourceUri=jmeter/load.jmx

      - name: Trigger delivery
        id: trigger-delivery
        uses: keptn/gh-action-send-event@main
        with:
          keptnApiUrl: ${{ steps.setup-keptn.outputs.KeptnAPIURL }}/v1/event
          keptnApiToken: ${{ steps.setup-keptn.outputs.KeptnAPIToken }}
          event: |
            {
              "data": {
                "configurationChange": {
                  "values": {
                    "control-plane": {
                      "enabled": true
                    }
                  }
                },
                "deployment": {
                  "deploymentURIsLocal": ["http://api-gateway-nginx.keptn-hardening"],
                  "deploymentstrategy": "direct"
                },
                "message": "",
                "project": "keptn",
                "result": "",
                "service": "keptn",
                "stage": "dev",
                "status": ""
              },
              "source": "gh",
              "specversion": "1.0",
              "type": "sh.keptn.event.dev.delivery.triggered",
              "shkeptnspecversion": "0.2.1"
            }

```