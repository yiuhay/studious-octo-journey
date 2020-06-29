module "labels" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  
  tags = {
    "environment" = var.env
    "project"     = var.project
    "owner"       = var.owner
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_prefix}-vnet"
  address_space       = [var.cidr_vnet]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  tags = module.labels.tags
}