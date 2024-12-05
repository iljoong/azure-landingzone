# Azure VM
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine.html

locals {
  app = {
      prefix = "${var.prefix}-app"
  }
}

# Create network interface
resource "azurerm_network_interface" "appnic" {
  count                     = var.appcount
  name                      = "${local.app.prefix}nic${count.index}"
  location                  = var.location
  resource_group_name       = data.azurerm_resource_group.tfrg.name

  ip_configuration {
    name      = "${local.app.prefix}-nicconfig${count.index}"
    subnet_id = data.azurerm_subnet.appsnet.id

    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "appnic" {
  count                     = var.appcount
  network_interface_id      = azurerm_network_interface.appnic[count.index].id
  network_security_group_id = data.azurerm_network_security_group.appnsg.id
}


/*
//ILB
resource "azurerm_network_interface_backend_address_pool_association" "apppoolassc" {
  count                   = var.appcount
  network_interface_id    = element(azurerm_network_interface.appnic.*.id, count.index)
  ip_configuration_name   = "${local.app.prefix}-nicconfig${count.index}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
}

resource "azurerm_network_interface_nat_rule_association" "apppoolassc" {
  count                   = var.appcount
  network_interface_id    = element(azurerm_network_interface.appnic.*.id, count.index)
  ip_configuration_name   = "${local.app.prefix}-nicconfig${count.index}"
  nat_rule_id             = azurerm_lb_nat_rule.lb.id
}
*/

// access through AppGW
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "appagwpoolassc" {
  count                   = var.appcount
  network_interface_id    = element(azurerm_network_interface.appnic.*.id, count.index)
  ip_configuration_name   = "${local.app.prefix}-nicconfig${count.index}"
  backend_address_pool_id = tolist(azurerm_application_gateway.tfappgw.backend_address_pool).0.id
}


resource "azurerm_availability_set" "appavset" {
  name                        = "${local.app.prefix}avset"
  location                    = var.location
  resource_group_name         = data.azurerm_resource_group.tfrg.name
  managed                     = "true"
  platform_fault_domain_count = 2 # default 3 not working in some regions like Korea

  tags = {
    environment = var.tag
  }
}

# Create virtual machine
resource "azurerm_virtual_machine" "appvm" {
  count                 = var.appcount
  name                  = "${local.app.prefix}vm${count.index}"
  location              = var.location
  resource_group_name   = data.azurerm_resource_group.tfrg.name
  network_interface_ids = [azurerm_network_interface.appnic[count.index].id]
  vm_size               = var.vmsize
  availability_set_id   = azurerm_availability_set.appavset.id

  storage_os_disk {
    name              = format("%s-%03d-osdisk", local.app.prefix, count.index + 1)
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  /*
  # custom image
  storage_image_reference {
    id = "${var.osimageuri}"
  }
  */

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = format("${local.app.prefix}vm%02d", count.index + 1)
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = file("./script/cloud-init-app.txt")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}

