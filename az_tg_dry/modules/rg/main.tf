resource "azurerm_resource_group" "rg" {
  location = var.location
  name     = "${var.resource_prefix}-rg"
}