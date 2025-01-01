locals {
    location = "Central India"
    resource_groups_name = "Hybrid-RG"

    virtual_networks = [
        {
            name = "Spoke-Vnet"
            address_space = ["20.0.0.0/16"]
        },
        {
            name = "Hub-Vnet"
            address_space = ["10.0.0.0/16"]
        },
        {
            name = "Onprem-Vnet"
            address_space = ["50.0.0.0/16"]
        }
    ]
    subnets = [
        {
            name = "Workload-SN"
            address_prefix = "20.0.0.0/24"
        },
        {
            name = "GatewaySubnet"
            address_prefix = "10.0.2.0/27"
        },
        {
            name = "AzureFirewallSubnet"
            address_prefix = "10.0.3.0/26"
        },
        {
            name = "Onprem-SN"
            address_prefix = "50.0.0.0/26"
        },
        {
            name = "GatewaySubnet"
            address_prefix = "50.0.2.0/27"
        }
    ]
    virtual_machines_names = [
        {
            name = "spoke-vm01"
        },
        {
            name = "onprem-vm01"
        }
    ]
}

variable "admin_username" {

    type = string
    description = "This is the admin username for the virtual machine"
  
}

variable "admin_password" {

    type = string
    description = "This is the admin password for the virtual machine"
}

variable "vm_sizes" {
    type = string
    description = "This is the Virtual Machine sizing"
    default = "Standard_B2s"
}
variable "offer" {

    type = string
    description = "This is the Offer for virtual machine Image" 
}

variable "publisher" {

    type = string
    description = "This is the Publisher of the Image"
}

variable "sku" {
    type = string
    description = "This is a SKU for the Machine"
  
}
