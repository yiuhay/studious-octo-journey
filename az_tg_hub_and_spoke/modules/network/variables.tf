variable "rg_prefix" {
  description = "Resource group name prefix"
  type        = string
}

variable "location" {
  description = "Azure region for deployment of resources."
  type        = string
}

variable "vnet_prefix" {
    description = "Virtual Network prefix."
    type        = string
}

variable "cidr_vnet" {
  description = "The address space that is used by the virtual network."
}

variable "snet_prefixes" {
  description = "The address prefix to use for the subnet."
  default     = ["10.0.1.0/24"]
}

variable "snet_names" {
  description = "A list of public subnets inside the vNet."
  default     = ["subnet1"]
}

variable "env" {}

variable "project" {}

variable "owner" {}