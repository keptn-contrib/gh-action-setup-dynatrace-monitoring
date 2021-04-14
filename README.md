# gh-action-setup-keptn

GH Action to spin up a GKE Cluster, install Keptn on it, and create Keptn as a project within itself. 
The output of this action provides the API credentials for the created Keptn instance.
In addition to Keptn, also the dynatrace-service and dynatrace-sli-service can be onboarded as services within the Keptn project.

## Parameters
| Name | Mandatory | Format | Description | Default |
|--|--|--|--|--|
| KeptnVersion | no | string | Version of Keptn to be installed | `0.8.1` |
| KeptnProject | no | string | Name of the Project used for Keptn self monitoring | `keptn` |
| KeptnProjectVersion | no | string | Version of the Keptn installation to be tested with Keptn | `0.8.1` |
| OnboardDynatraceService | no | string | Indicates whether the dynatrace-service should be onboarded | `false` |
| DynatraceServiceVersion | no | string | Version of the dynatrace-service | `0.13.0` |
| OnboardDynatraceSLIService | no | string | Indicates whether the dynatrace-sli-service should be onboarded | `false` |
| DynatraceSLIServiceVersion | no | string | Version of the dynatrace-sli-service | `0.10.0` |
| GKEClusterVersion | no | string | Version of the GKE Cluster | `1.18` |
| GKEClusterRegion | no | string | Region of the GKE Cluster | `us-east1` |
| GKEProjectName | yes | string | Name of the GKE Project | - |
| GKEClusterName | yes | string | Name of the GKE Cluster | - |
| GKEClusterMachineType | no | string | Name of the machine type used for the GKE Cluster | `n1-standard-4` |
| GKEClusterNumNodes | no | int | Number of nodes for the GKE Cluster | `3` |
| GCloudComputeZone | no | string | Name of the GCloud compute Zone | `us-east1-b` |
| GCloudServiceKey | yes | string | Base64 encoded GCloud service Key JSON | - |


### Outputs
| Name | Format | Description |
|--|--|--|--|
| KeptnAPIUrl | url | Keptn API URL | 
| KeptnAPIToken | string | Keptn API Token |

## Example usage

```yaml
name: Setup Keptn
on:
  - workflow_dispatch

jobs:
  send_keptn_event:
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
  
      # The Keptn API credentials can then be used in the next action, e.g.:
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
                  "deploymentURIsLocal": null,
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