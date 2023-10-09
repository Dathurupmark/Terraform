variable "rsgname" {
    type = string
    description = "used for naming resource group"
}

variable "rsglocation"{
    type = stringdescription = "used for select the location"
    default = "eastus"
}

variable "prefix"{
    type = string
    description = "used for define standard prefix for all resource"
    }

vaiable "vnet_cidr_prefix" {
    type = string 
    description = "this variable defines address space for vnet"
}

vaiable "subnet1_cidr_prefix" {
    type = string 
    description = "this variable defines address space for subnet1"
}

