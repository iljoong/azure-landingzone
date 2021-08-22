## RBAC

You can define custom roles for landing zone as below. Assign this role to specific user in your subscription.

| Role | Usage | Actions | No actions |
|---|---|---|---|
| Azure platform owner               | Management group and subscription lifecycle management                                                           | `*`                                                                                                                                                                                                                  |                                                                                                                                                                                         |
| Network management (NetOps)        | Platform-wide global connectivity management: VNets, UDRs, NSGs, NVAs, VPN, ExpressRoute, and others            | `*/read`, `Microsoft.Authorization/*/write`, `Microsoft.Network/vpnGateways/*`, `Microsoft.Network/expressRouteCircuits/*`, `Microsoft.Network/routeTables/write`, `Microsoft.Network/vpnSites/*`                              |                                                                                                                                                                               |
| Security operations (SecOps)       | Security administrator role with a horizontal view across the entire Azure estate and the Azure Key Vault purge policy | `*/read`, `*/register/action`, `Microsoft.KeyVault/locations/deletedVaults/purge/action`, `Microsoft.Insights/alertRules/*`, `Microsoft.Authorization/policyDefinitions/*`, `Microsoft.Authorization/policyAssignments/*`, `Microsoft.Authorization/policySetDefinitions/*`, `Microsoft.PolicyInsights/*`, `Microsoft.Security/*` |                                                                            |
| Subscription owner (InfraOps)      | Delegated role for subscription owner derived from subscription owner role                                       | `*`                                                                                                                                                                                                                  | `Microsoft.Authorization/*/write`, `Microsoft.Network/vpnGateways/*`, `Microsoft.Network/expressRouteCircuits/*`, `Microsoft.Network/routeTables/write`, `Microsoft.Network/vpnSites/*` |
| Application owners (DevOps/AppOps) | Contributor role granted for application/operations team at resource group level                                 | `*`                                                                                                                                                                                                                | `Microsoft.Network/publicIPAddresses/write`, `Microsoft.Network/virtualNetworks/write`, `Microsoft.KeyVault/locations/deletedVaults/purge/action`                                         |


https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/enterprise-scale/identity-and-access-management

### Role Definition

- [NetOps role definition](./role_netops.json)
- [SecOps role definition](./role_secops.json)
- [AppOps role definition](./role_appops.json)

## CLI

Sample `AppOps` role grants contributor permission except, _creating Public IP and VNet_ and purging KV. 

```
az role definition create --role-definition role_appops.json

az role assignment create --assignee {object id of user or group} --role 'AppOps' --scope '/subscriptions/{subscription id}'
```



https://docs.microsoft.com/en-us/cli/azure/role/definition?view=azure-cli-latest

> :warining: You cannot assign `CustomRole` in Blueprint.

## Reference

https://docs.microsoft.com/en-us/azure/role-based-access-control/overview
https://docs.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles
https://docs.microsoft.com/en-us/azure/role-based-access-control/custom-roles
https://docs.microsoft.com/en-us/azure/role-based-access-control/role-definitions
