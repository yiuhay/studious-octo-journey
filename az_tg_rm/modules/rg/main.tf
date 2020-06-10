terraform {
  required_version = ">= 0.12"
}

resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.resource_prefix}-rg"

  tags     = var.tags
}