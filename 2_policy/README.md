## Built-in Policy

Examples of built-in policies.

- [Allowed VM size SKU](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Compute/VMSkusAllowed_Deny.json)

- [Enable Azure Security Center on your subscription](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Security%20Center/ASC_Register_To_Azure_Security_Center_Deploy.json)

- [Deploy Log Analytics agent for Linux VMs](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Monitoring/LogAnalyticsExtension_Linux_VM_Deploy.json)

For more built-in polices, see [https://docs.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies](https://docs.microsoft.com/en-us/azure/governance/policy/samples/built-in-policies) for more information.

> To enable OS metrics in Log Analytics, see [documentation](https://docs.microsoft.com/en-us/azure/azure-monitor/learn/quick-collect-linux-computer)

## Sample Custom Policy

> Sample policies at github: https://github.com/Azure/azure-policy/tree/master/samples/Monitoring

### NSG flow log

this policy _deploy-if-not-exist_ NSG flow log to both Storage account and Log Analytics account

You need manually copy values to the parameters when assigning the policy.

| parameter       | value |
|-----------------|-------|
| storage id      | /subscriptions/{subscription_id}/resourceGroups/{resourcegroup_name}/providers/Microsoft.Storage/storageAccounts/{storage_name} |
| loganalytics id | 9fe24170-1111-2222-3333-a80ab16e9753 |
| logana res id   | /subscriptions/{subscription_id}/resourceGroups/{resourcegroup_name}/providers/microsoft.operationalinsights/workspaces/{workspace_name} |

### WAF log

this policy _deploy-if-not-exist_ WAF log (`ApplicationGatewayAccessLog`, `ApplicationGatewayFirewallLog`) to Log Analytics account

## CLI

CLI to create policy definition

```powershell
Get-Content .\policy-deploy-waf-log.json | ConvertFrom-Json | % { $_.parameters } | ConvertTo-Json -Depth 10 > _params.json
Get-Content .\policy-deploy-waf-log.json | ConvertFrom-Json | % { $_.policyRule } | ConvertTo-Json -Depth 10 > _rules.json

az policy definition create --name 'test-deploy-waf-log' `
    --mode all --rules _rules.json `
    --params _params.json `
    --metadata "category=test" `
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
