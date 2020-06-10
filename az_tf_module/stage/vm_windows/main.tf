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

data "azurerm_resource_group" "rg" {
  name = "ang-stage-rg"
}

data "azurerm_subnet" "snet_internal" {
  name                 = "snet-internal"
  virtual_network_name = "ang-stage-vnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

module "vm_windows" {
  source = "../../modules/vm_windows"

  resource_prefix  = "ang-stage"
  rg_name          = data.azurerm_resource_group.rg.name
  rg_location      = data.azurerm_resource_group.rg.location
  snet_internal_id = data.azurerm_subnet.snet_internal.id
  win_admin        = var.win_admin
}