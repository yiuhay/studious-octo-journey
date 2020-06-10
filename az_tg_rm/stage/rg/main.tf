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

module "rg" {
  source = "../../modules/rg"

  location = "uksouth"
  resource_prefix = "ang-stage"
  
}