## Customization note

For sample policy definitions, please see [github samples](https://github.com/Azure/azure-policy/tree/master/samples/Monitoring)

- Note on NSG flow log (some special Azure resource)

`NSG flow log` does not belong to `NSG` itself. It belongs to `NetworkWatcher` and it is global resource that predefined resources. It has predefined resource group name, `NetworkWatcherRG` and resource name, `NetworkWatcher_<region>` (e.g., `NetworkWatcher_koreacentral`).

- Understand diagnostic template structure

For NSG flow log, you'll need a ARM template deployment snippet (i.e., properties settings).
https://docs.microsoft.com/en-us/azure/network-watcher/network-watcher-nsg-flow-logging-azure-resource-manager

Alternatively, you can use REST API to get the properties settings from existing resource.

For example, POSTMAN or similar tool to get properties of diagnostic settings of (nsg flow log)[https://docs.microsoft.com/en-us/rest/api/network-watcher/flowlogs/get]

REST api
```
GET https://management.azure.com/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/providers/Microsoft.Network/networkWatchers/{networkWatcherName}/flowLogs/{flowLogName}?api-version=2020-05-01
```

result:
```json
      "properties": {
        "provisioningState": "Succeeded",
        "targetResourceId": "/subscriptions/{subscription_id}/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/test-vnet-nsg",
        "targetResourceGuid": "a8490576-3c62-4a99-96ae-9370781ba95d",
        "storageId": "/subscriptions/{subscription_id}/resourceGroups/demo-loganalytics/providers/Microsoft.Storage/storageAccounts/stordemo",
        "enabled": true,
        "flowAnalyticsConfiguration": {
          "networkWatcherFlowAnalyticsConfiguration": {
            "enabled": true,
            "workspaceId": "9fe24170-1111-2222-3333-a80ab16e9753",
            "workspaceRegion": "koreacentral",
            "workspaceResourceId": "/subscriptions/{subscription_id}/resourcegroups/demo-la-rg/providers/microsoft.operationalinsights/workspaces/demo-la",
            "trafficAnalyticsInterval": 60
          }
        },
        "retentionPolicy": {
          "days": 0,
          "enabled": false
        },
        "format": {
          "type": "JSON",
          "version": 1
        }
      },
```
## Diagnostic Settings

Other than NSG flow log, most of Azure resource diagnostics settings in ARM template format are similar.

```json
"properties": {
    "workspaceId": "[parameters('logAnalytics')]",
    "metrics": [
        {
            "category": "AllMetrics",
            "enabled": "[parameters('metricsEnabled')]",
            "retentionPolicy": {
                "enabled": false,
                "days": 0
            }
        }
    ],
    "logs": [
        {
            "category": "ApplicationGatewayAccessLog",
            "enabled": "[parameters('logsEnabled')]"
        },
        {
            "category": "ApplicationGatewayFirewallLog",
            "enabled": "[parameters('logsEnabled')]"
        }                                            
    ]
}
```

You can get properties value from following REST API.

```
GET https://management.azure.com/subscriptions/{{subscriptionId}}/resourceGroups/{{resourceGroupName}}/providers/{{resourceType}}/{{resourceName}}/providers/Microsoft.insights/diagnosticSettings?api-version=2017-05-01-preview
```

You can also get list of _diagnostics setting category_ using REST API. See [documentation](https://docs.microsoft.com/en-us/rest/api/monitor/diagnosticsettingscategory/list)

## Troubleshooting

1. Assignment delay

Note that, Policy does not trigger immediately after resource is created. It takes ~10 min to initiate the assignment process. Check `Azure Activity log` for progress.

2. Error during assignment

Because NSG flow log is belonging to NetworkWatch so that if you assign permission only in a certain resource group, you may experience `Authorization failed` error.

```
Deployment failed with multiple errors: 'Authorization failed for template resource 'flowlogDeployment-test-vnet-nsg' of type 'Microsoft.Resources/deployments'. The client 'a2b0acfc-37a7-4ae4-8132-13dd36e3beee' with object id 'a2b0acfc-37a7-4ae4-8132-13dd36e3beee' does not have permission to perform action 'Microsoft.Resources/deployments/write' at scope '/subscriptions/399042cf-1111-2222-3333-91f652d4ffc1/resourceGroups/NetworkWatcherRG/providers/Microsoft.Resources/deployments/flowlogDeployment-test-vnet-nsg'.:Authorization failed for template resource 'networkwatcher_koreacentral/Microsoft.Networktest-vnet-nsg' of type 'Microsoft.Network/networkWatchers/flowLogs'. The client 'a2b0acfc-37a7-4ae4-8132-13dd36e3beee' with object id 'a2b0acfc-37a7-4ae4-8132-13dd36e3beee' does not have permission to perform action 'Microsoft.Network/networkWatchers/flowLogs/write' at scope '/subscriptions/{subscription_id}/resourceGroups/NetworkWatcherRG/providers/Microsoft.Network/networkWatchers/networkwatcher_koreacentral/flowLogs/Microsoft.Networktest-vnet-nsg'.'
```

You also need to enable `"assignPermissions": "true"` in `parameter` section. 

```
Evaluation of DeployIfNotExists policy was unsuccessful. The policy assignment '/subscriptions/{subscription_id}/resourceGroups/test-rg/providers/Microsoft.Authorization/policyAssignments/1c21f96844444b0cb677bb53/' resource identity does not have the necessary permissions. Please see https://aka.ms/arm-policy-identity for usage details
```

> https://docs.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure#parameter-properties

3. Role definition

`/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c` is `Contributor` role