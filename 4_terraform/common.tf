# Configure the Microsoft Azure Provider
provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

data "azurerm_resource_group" "tfrg" {
  name = "${var.prefix}-app-rg"
}

data "azurerm_virtual_network" "tfvnet" {
  name                = "${var.prefix}-vNET"
  resource_group_name = data.azurerm_resource_group.tfrg.name
}

data "azurerm_subnet" "appgwsnet" {
  name                = "AppGWSubnet"
  virtual_network_name = data.azurerm_virtual_network.tfvnet.name
  resource_group_name  = data.azurerm_resource_group.tfrg.name
}

data "azurerm_subnet" "appsnet" {
  name                = "CoreSubnet"
  virtual_network_name = data.azurerm_virtual_network.tfvnet.name
  resource_group_name  = data.azurerm_resource_group.tfrg.name
}

data "azurerm_network_security_group" "appnsg" {
  name                = "${var.prefix}-Core-NSG"
  resource_group_name = data.azurerm_resource_group.tfrg.name
}

output "appgw_private_ip" {
  value = format("%s.4", regex("(\\d{1,3}.\\d{1,3}.\\d{1,3}).*$", data.azurerm_subnet.appgwsnet.address_prefixes[0])[0])
}