variable "rg_prefix" {
  description = "Resource Group prefix."
  type        = string
}

variable "vnet_prefix" {
  description = "Virtual Network prefix."
  type        = string
}

variable "snet_name" {
  description = "Subnet name to place VM"
  type        = string
}

variable "vm_prefix" {
  description = "Virtual Machine prefix."
  type        = string
}

variable "instance_count" {
  description = "vm count"
  type = number
}

variable "win_admin_password" {
  description = "Key Vault Secret Name"
}

variable "vm_size" {
  description = "vm size"
  type        = string
}

variable "additional_data_disk" {
  description = "Specify if an additional Data Disks should be created for each VM"
  default = false
}

variable "data_disk_type" {
  description = "Standard_LRS, StandardSSD_LRS, Premium_LRS or UltraSSD_LRS"
  type        = string
}

variable "data_disk_size" {
  description = "size in GB"
  type = string
}


variable "env" {}

variable "project" {}

variable "owner" {}