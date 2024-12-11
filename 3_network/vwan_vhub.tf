resource "azurerm_virtual_hub" "demo" {
  name                = "${var.location}-vhub"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  virtual_wan_id      = azurerm_virtual_wan.demo.id
  address_prefix      = "10.100.0.0/24"

  virtual_router_auto_scale_min_capacity = 2
  hub_routing_preference                 = "ExpressRoute"

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}

resource "azurerm_virtual_hub_connection" "vnet1" {
  name                      = "conn-vnet1"
  virtual_hub_id            = azurerm_virtual_hub.demo.id
  remote_virtual_network_id = azurerm_virtual_network.demo[0].id

  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.blue.id
    propagated_route_table {
        route_table_ids = [data.azurerm_virtual_hub_route_table.default.id]
    }
  }
}

resource "azurerm_virtual_hub_connection" "vnet2" {
  name                      = "conn-vnet2"
  virtual_hub_id            = azurerm_virtual_hub.demo.id
  remote_virtual_network_id = azurerm_virtual_network.demo[1].id

  routing {
    associated_route_table_id = data.azurerm_virtual_hub_route_table.default.id
    propagated_route_table {
        route_table_ids = [data.azurerm_virtual_hub_route_table.default.id, 
            azurerm_virtual_hub_route_table.blue.id,
            azurerm_virtual_hub_route_table.red.id]
    }
  }
}

resource "azurerm_virtual_hub_connection" "vnet3" {
  name                      = "conn-vnet3"
  virtual_hub_id            = azurerm_virtual_hub.demo.id
  remote_virtual_network_id = azurerm_virtual_network.demo[2].id

  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.red.id
    propagated_route_table {
        route_table_ids = [data.azurerm_virtual_hub_route_table.default.id]
    }
  }
}

resource "azurerm_virtual_hub_route_table" "blue" {
  name           = "rt-blue"
  virtual_hub_id = azurerm_virtual_hub.demo.id
  labels         = ["rt-blue"]
}

resource "azurerm_virtual_hub_route_table" "red" {
  name           = "rt-red"
  virtual_hub_id = azurerm_virtual_hub.demo.id
  labels         = ["rt-red"]
}

data "azurerm_virtual_hub_route_table" "default" {
  name           = "defaultRouteTable"
  virtual_hub_name = azurerm_virtual_hub.demo.name
  resource_group_name = azurerm_resource_group.demo.name

  depends_on = [ azurerm_virtual_hub.demo ]
}