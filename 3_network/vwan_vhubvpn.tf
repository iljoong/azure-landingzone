resource "azurerm_vpn_server_configuration" "demo" {
  name                     = "example-config"
  resource_group_name      = azurerm_resource_group.demo.name
  location                 = var.location
  vpn_authentication_types = ["Certificate"]

  client_root_certificate {
    name             = "RootCert"
    public_cert_data = <<EOF
${replace(replace(file("./PS2RootCert.cer"), "-----BEGIN CERTIFICATE-----\r\n", ""), "-----END CERTIFICATE-----\r\n", "")}
EOF
  }
}

resource "azurerm_point_to_site_vpn_gateway" "demo" {
  name                        = "${var.prefix}-vpngw"
  location                    = var.location
  resource_group_name         = azurerm_resource_group.demo.name

  virtual_hub_id              = azurerm_virtual_hub.demo.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.demo.id
  scale_unit                  = 1

  connection_configuration {
    name = "P2SConnectionConfigDefault"

    vpn_client_address_pool {
      address_prefixes = [
        "10.110.0.0/24"
      ]
    }
  }
}