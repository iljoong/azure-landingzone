# README

This sample demonstrates how to setup/govern Azure environment using landing zone concept. 

- Centralized logging/monitoring to Storage account/Log Analytics
- Enforce logging and baseline policies using _Azure Policy_
- Automate landing zone using _Azure Blueprint and Terraform_

> Prerequisites: _Storage account_ and _Log Analytics_ are required in order to run this sample

![landing zone architecture](./architecture.png)
## Azure Policy

Set baseline governance policy for the application landing zone.

- VM SKU: enforce only certain VM SKU can be deployed in this subscription
- NSG Flow log: automatically enable NSG Flow log 
- WAF log: automatically enable WAF log
- RBAC: InfraOps and AppOps

## Azure Blueprint

Build basic infrastructure landing zone.

- Resource group
- Virtual network with 5 subnets, including `AppGWSunet` and `CoreSubnet`
- NSGs
- Lock resources (vnet and NSGs)
- Storage account

## Terraform

Deploy application landing zone.

- App Gateway with complex configuration, including HTTP and HTTPs config.
- VMs with NGNIX setup

