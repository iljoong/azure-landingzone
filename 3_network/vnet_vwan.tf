resource "azurerm_virtual_network" "demo" {
  count               = 3
  name                = "${var.prefix}-vnet-${count.index+1}"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  address_space = [format("10.10%d.0.0/16", count.index+1)]

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}

resource "azurerm_subnet" "demo" {
  count               = 3
  name                = "default"
  virtual_network_name = azurerm_virtual_network.demo[count.index].name
  resource_group_name  = azurerm_resource_group.demo.name
  address_prefixes = [format("10.10%d.0.0/24", count.index+1)]
}

resource "azurerm_network_security_group" "demo" {
  name                = "${var.prefix}-subnet-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.demo.name

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 2001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}

resource "azurerm_subnet_network_security_group_association" "demo" {
  count                     = 3
  subnet_id                 = azurerm_subnet.demo[count.index].id
  network_security_group_id = azurerm_network_security_group.demo.id
}

resource "azurerm_virtual_wan" "demo" {
  name                = "${var.prefix}-vwan"
  resource_group_name = azurerm_resource_group.demo.name
  location            = var.location

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}