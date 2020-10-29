variable name { type = string } #skgc-vrd-prod-koce-001-udr
variable location { type = string }
variable rg { type = string }
variable tags { }

resource "azurerm_route_table" "routetable" {
  name                          = "${var.name}-001-udr"
  location                      = var.location
  resource_group_name           = var.rg
  disable_bgp_route_propagation = true

  route = [
    {
      name           = "vrd-AZhubfw01"
      address_prefix = "10.242.2.133/32"
      next_hop_type  = "VirtualAppliance"
      next_hop_in_ip_address = "10.242.2.133"
    },
    {
      name           = "vrd-AZhubfw02"
      address_prefix = "10.242.2.134/32"
      next_hop_type  = "VirtualAppliance"
      next_hop_in_ip_address = "10.242.2.134"
    },
    {
      name           = "vrd-hub"
      address_prefix = "10.242.0.0/21"
      next_hop_type  = "VirtualAppliance"
      next_hop_in_ip_address = "10.242.2.132"
    },
    {
      name           = "vrd-ingresslb"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "VirtualAppliance"
      next_hop_in_ip_address = "10.242.2.132"
    }
  ]

  tags = var.tags
}

output "id" {
  value = azurerm_route_table.routetable.id
}