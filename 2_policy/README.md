## Built-in Policy

Examples of built-in policies/initiatives.

- [Append a tag and its value to resources](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Tags/ApplyTag_Append.json)
- [Allowed VM size SKU](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Compute/VMSkusAllowed_Deny.json)

- [Configure your Storage account public access to be disallowed](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Storage/StorageAccountDisablePublicBlobAccess_Modify.json)      
    - Note: _Public access_ means __anonymous access__ and NOT __public internet access__. (This can be configured in Configuration setttings.)

- [Configure Microsoft Defender CSPM to be enabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Security%20Center/ASC_Azure_Defender_CSPM_DINE.json)

- [Configure diagnostic settings for Blob Services to Log Analytics workspace](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Storage/BlobServicesLogsToWorkspace_DINE.json)

- [Enable Azure Monitor for VMs with Azure Monitoring Agent(AMA)](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policySetDefinitions/Monitoring/AzureMonitor_VM_AMA_new.json)

To enable OS metrics in Log Analytics, see [documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/monitor-virtual-machine)

For more built-in polices, see [https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies](https://learn.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies) for more information.

## Sample Custom Policy

> Sample policies at github: https://github.com/Azure/azure-policy/tree/master/samples/Monitoring

### NSG flow log

For NSG flow log, see https://learn.microsoft.com/en-us/azure/network-watcher/nsg-flow-logs-policy-portal

### WAF log

> Updated for new `Diagnostics` ARM template. See the [document](https://learn.microsoft.com/en-us/azure/templates/microsoft.insights/diagnosticsettings?pivots=deployment-language-arm-template) for more information.

this policy _deploy-if-not-exist_ WAF log (`ApplicationGatewayAccessLog`, `ApplicationGatewayPerformanceLog`, `ApplicationGatewayFirewallLog`) to Log Analytics account

## CLI

CLI to create policy definition for _custom public access policy_.

Windows:

```powershell
Get-Content .\policy-storage-public-access-audit.json | ConvertFrom-Json | % { $_.parameters } | ConvertTo-Json -Depth 15 > _params.json
Get-Content .\policy-storage-public-access-audit.json | ConvertFrom-Json | % { $_.policyRule } | ConvertTo-Json -Depth 15 > _rules.json

az policy definition create --name 'test-storage-public-access-audit' `
    --mode all --rules _rules.json `
    --params _params.json `
    --metadata "category=test" `
    --subscription $subscriptionid
```

Linux:

> You may need to install `jq`.

```bash
cat policy-storage-public-access-audit.json | jq .parameters > _params.json
cat policy-storage-public-access-audit.json | jq .policyRule > _rules.json

az policy definition create --name 'test-storage-public-access-audit' \
    --mode all --rules _rules.json \
    --params _params.json \
    --metadata "category=test" \
    --subscription $subscriptionid
```

> Reference: https://docs.microsoft.com/en-us/cli/azure/policy/definition?view=azure-cli-latest

## PowerShell Tool for Diagnostics Policy

`Create-AzDiagPolicy` is a tool that enables Azure diagnostics in your subscription.

https://www.powershellgallery.com/packages/Create-AzDiagPolicy

```powershell
save-script -name create-azdiagpolicy -Path . -Repository PSGallery

get-help .\Create-AzDiagPolicy.ps1 -example

.\Create-AzDiagPolicy.ps1 -ExportLA -ExportDir .\DiagPolicyExport -ValidateJSON -SubscriptionId "{subscription id}"
```

![Create-AzDiagPolicy](./azdiagpolicy.png)
