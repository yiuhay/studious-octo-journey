variable "location" {
    description = "Azure region for deployment of resources."
    type        = string
    default     = "uksouth"
}

variable "resource_prefix" {
    description = "Service prefix to use for naming of resources."
    type        = string
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
  default     = {}
}