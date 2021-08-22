# App Gateway
# https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html

resource "azurerm_public_ip" "appgw" {
  name                = "${var.prefix}-appgw-pip"
  resource_group_name = data.azurerm_resource_group.tfrg.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  availability_zone   = "No-Zone"

  tags = {
    environment = var.env
    costcenter = var.tag
  }
}

// install cert from local pfx file
data "local_file" "cert" {
    filename = var.certpath
}

resource "azurerm_application_gateway" "tfappgw" {
  name                = "${var.prefix}-appgw"
  resource_group_name = data.azurerm_resource_group.tfrg.name
  location            = var.location

  # V2 does not support private ip only
  # https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-faq#how-do-i-use-application-gateway-v2-with-only-private-frontend-ip-address
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  
  // install cert from local pfx file
  ssl_certificate {
    name     = "sslcert"
    data     = data.local_file.cert.content_base64
    password = var.certpassword
  }
  
  /*
  // install cert from KV
  // https://docs.microsoft.com/en-us/azure/application-gateway/key-vault-certs
  // KV must *must be enabled "soft delete feature"*, Identity (to access KV) must be assigned
  ssl_certificate {
    name                = "sslcert"
    key_vault_secret_id = var.kvcertid
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [var.useridentity]
  }
  */

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = data.azurerm_subnet.appgwsnet.id
  }

  frontend_ip_configuration {
    name                 = "appgw-fe-pip"
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  frontend_ip_configuration {
    name                          = "appgw-fe-ip"
    subnet_id                     = data.azurerm_subnet.appgwsnet.id
    private_ip_address_allocation =  "Static"
                                    // may not work for all address prefix 
    private_ip_address            = format("%s.4", regex("(\\d{1,3}.\\d{1,3}.\\d{1,3}).*$", data.azurerm_subnet.appgwsnet.address_prefixes[0])[0]) //"10.100.1.4"
  }

  probe {
      name                = "health-probe"
      protocol            = "http"
      host                = "127.0.0.1"
      path                = "/"
      interval            = 15
      timeout             = 5
      unhealthy_threshold = 3
  }

  # rule - production
  request_routing_rule {
    name                       = "http-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http80"

    /*backend_address_pool_name  = "wafpool"
    backend_http_settings_name = "http-settings"*/

    redirect_configuration_name = "httpredirect"
  }

  request_routing_rule {
    name                       = "https-rule"
    rule_type                  = "Basic"
    http_listener_name         = "https"

    backend_address_pool_name  = "wafpool"
    backend_http_settings_name = "http-settings"
  }

  redirect_configuration {
    name                          = "httpredirect"
    redirect_type                 = "Permanent"
    target_listener_name          = "https"
    include_path                  = true
    include_query_string          = true
  }

  http_listener {
    name                           = "http80"
    frontend_ip_configuration_name = "appgw-fe-pip"
    frontend_port_name             = "port80"
    protocol                       = "Http"
  }

  http_listener {
    name                           = "https"
    frontend_ip_configuration_name = "appgw-fe-pip"
    frontend_port_name             = "port443"
    protocol                       = "Https"
    ssl_certificate_name           = "sslcert"
  }

  frontend_port {
    name = "port80"
    port = 80
  }

  frontend_port {
    name = "port443"
    port = 443
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    #path                  = "/path1/"
    port                  = 80
    probe_name            = "health-probe"
    protocol              = "Http"
    request_timeout       = 5
  }

  backend_address_pool {
    name         = "wafpool"
  }
}

output "waf_ip_address" {
  value = azurerm_public_ip.appgw.ip_address
}

/*
// Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "appgw" {
  name               = "appgw-diagnostics"
  target_resource_id = azurerm_application_gateway.tfappgw.id
  log_analytics_workspace_id = var.diagworkspaceid
  storage_account_id         = var.diagstorage
  log {
    category = "ApplicationGatewayAccessLog"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "ApplicationGatewayFirewallLog"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
}
*/