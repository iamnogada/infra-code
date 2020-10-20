terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}




resource "azurerm_application_gateway" "skgc-vrd-prod-appgw" {
  name                = "skgc-vrd-prod-appgw"
  resource_group_name = var.resourcegroup
  location            = var.location

  enable_http2 = true
  autoscale_configuration{
    min_capacity = 1
    max_capacity = 4
  }
  sku {
    name     = "WAF_v2"
    tier     = "WAF_V2"
  }

  waf_configuration {
    enabled          = "true"
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.0"
  }

  gateway_ip_configuration {
    name      = "subnet"
    subnet_id = var.dmz_subnet_id
  }

  frontend_port {
    name = "http"
    port = 80
  }
  # frontend_port {
  #   name = "https"
  #   port = 443
  # }

  frontend_ip_configuration {
    name                 = "frontend"
    public_ip_address_id = "/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourceGroups/skgc-vrd-prod-koce-dmz-rg/providers/Microsoft.Network/publicIPAddresses/skgc-appgw-pip"
  }

  backend_address_pool {
    name = "skgc-vrd-aks"
  }

  http_listener {
    name                           = "http"
    frontend_ip_configuration_name = "frontend"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  probe {
    name                = "probe"
    protocol            = "http"
    path                = "/"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
    host = "127.0.0.1"
  }

  backend_http_settings {
    name                  = "http"
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
    backend_address_pool_name  = "skgc-vrd-aks"
    backend_http_settings_name = "http"
  }

  tags = {
    "Application or Service Name" = "vrd"
    "Environment"                 = "prod"
    "Operated By"                 = "skcc-cloudops"
    "Owner"                       = "skgc"
  }
}
