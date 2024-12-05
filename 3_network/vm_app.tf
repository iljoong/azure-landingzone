# Azure VM
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine.html

locals {
  app = {
      prefix = "${var.prefix}-vm"
  }
}
resource "azurerm_public_ip" "demo" {
  count               = 3
  name                = "${local.app.prefix}-pip${count.index+1}"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}

# Create network interface
resource "azurerm_network_interface" "demo" {
  count                     = 3
  name                      = "${local.app.prefix}-nic${count.index+1}"
  location                  = var.location
  resource_group_name       = azurerm_resource_group.demo.name

  ip_configuration {
    name      = "${local.app.prefix}-nicconfig${count.index+1}"
    subnet_id = azurerm_subnet.demo[count.index].id

    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.demo[count.index].id
  }

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}

resource "azurerm_network_interface_security_group_association" "demo" {
  count                     = 3
  network_interface_id      = azurerm_network_interface.demo[count.index].id
  network_security_group_id = azurerm_network_security_group.demo.id
}

# Create virtual machine
resource "azurerm_virtual_machine" "demo" {
  count                 = 3
  name                  = "vnet${count.index+1}-vm"
  location              = var.location
  resource_group_name   = azurerm_resource_group.demo.name
  network_interface_ids = [azurerm_network_interface.demo[count.index].id]
  vm_size               = var.vmsize

  storage_os_disk {
    name              = format("%s%d-osdisk", local.app.prefix, count.index + 1)
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_profile {
    computer_name  = format("vnet%dvm", count.index + 1)
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

