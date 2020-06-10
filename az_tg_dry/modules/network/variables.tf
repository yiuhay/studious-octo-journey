variable "resource_prefix" {
    description = "Service prefix to use for naming of resources."
    type        = string
}

variable "vnet_cidr" {
  description = "The address space that is used by the virtual network."
}

variable "rg_name" {
  description = "Resource group name"
  type        = string
}

variable "rg_location" {
  description = "Azure region for deployment of resources."
  type        = string
}

variable "bastion_cidr" {
  description = "The address space that is used by the bastion."  
}

variable "internal_cidr" {
  description = "The address space that is used by the internal vm."  
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
  default     = {}
}