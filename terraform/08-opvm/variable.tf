variable subscription_id {
    type = string
    description=" tenant's subscription id"
}

variable location {
    type = string
    default ="koreacentral"
}

variable devops_resourcegroup {
    type = string
    default=""
}
variable devops_subnet_id {
    type=string
    default=""
}

variable devops_vm_name {
    type = string
    default=""
}
variable op_subnet_id {
    type=string
    default=""
}

variable op_vm_name {
    type = string
    default=""
}
