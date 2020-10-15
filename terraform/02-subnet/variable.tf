variable subscription_id {
    type = string
    description=" tenant's subscription id"
}

variable location {
    type = string
    default ="koreacentral"
}

variable default_vnet {
    type = string
}
variable default_resourcegroup {
    type=string
}

variable default_route_id {
    type=string
}

variable vrd_dmz_subnet{
    type = list(object({
        name = string
        cidr = list(string)
    }))
    default = []
}
variable vrd_private_subnet{
    type = list(object({
        name = string
        cidr = list(string)
    }))
    default = []
}
# variable vrd_prod_subnets{
#     type = map
#     default = {}
# }