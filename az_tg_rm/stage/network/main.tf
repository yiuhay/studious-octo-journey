terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version         = "=2.6.0"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

terraform {
  backend "azurerm" {}
}

data "azurerm_resource_group" "rg" {
  name = "ang-stage-rg"
}

module "network" {
  source = "../../modules/network"

  resource_prefix = "ang-stage"
  vnet_cidr       = "10.69.0.0/16"
  rg_name         = data.azurerm_resource_group.rg.name
  rg_location     = data.azurerm_resource_group.rg.location

  bastion_cidr    = "10.69.11.0/24"
  internal_cidr   = "10.69.7.0/24"
}