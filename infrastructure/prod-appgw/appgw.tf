variable appgw {
  type = object({
    name = string
    cidr = list(string)
  })
  default = {
    name = "appgw"
    cidr = ["10.242.17.0/25"]
  }
}

######## subnet
module "appgw" {
  source = "../modules/subnet"
  name   = "${module.const.long-name}-${var.appgw.name}" #"skgc-vrd-prod-devops-koce"
  rg     = module.const.rg
  vnet   = module.const.vnet
  cidr   = var.appgw.cidr

}

########  resource group
resource "azurerm_resource_group" "rg" {
  name     = "${module.const.long-name}-appgw-rg"
  location = module.const.location
  tags     = module.const.tags
}

########  public ip
resource "azurerm_public_ip" "appgw" {
  name                = "AZ${var.appgw.name}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  domain_name_label   = "skgcvrd"
  # must Standard for WAF_V2
  sku  = "Standard"
  tags = module.const.tags
}

######## appgw
locals {
  backend_address_pool_name  = "skgc-vrd-aks"
  frontend_port              = "http_port"
  backend_http_settings_name = "aks_setting"
  frontend_ip_configuration  = "edge_ip"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${module.const.long-name}-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  enable_http2 = true
  autoscale_configuration {
    min_capacity = 1
    max_capacity = 4
  }
  sku {
    name = "WAF_v2"
    tier = "WAF_V2"
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "public"
    subnet_id = module.appgw.id
  }

  frontend_port {
    name = local.frontend_port
    port = 80
  }
  # frontend_port {
  #   name = "https"
  #   port = 443
  # }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration
    public_ip_address_id = azurerm_public_ip.appgw.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = local.frontend_ip_configuration
    frontend_port_name             = local.frontend_port
    protocol                       = "Http"
  }

  probe {
    name                = "probe"
    protocol            = "http"
    path                = "/"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
    host                = "127.0.0.1"
  }

  backend_http_settings {
    name                  = local.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
    probe_name            = "probe"

  }

  request_routing_rule {
    name                       = "http"
    rule_type                  = "Basic"
    http_listener_name         = "http"
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_settings_name
  }

  tags = module.const.tags
}


