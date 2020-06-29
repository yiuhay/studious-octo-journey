locals {
  default_yaml_path = "env.yaml"

  global = yamldecode(
    file("env.yaml")
  )
}

remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "${local.global.rg_prefix}-secret-rg"
    storage_account_name = local.global.storage_account_name
    container_name       = "${local.global.rg_prefix}-container"
    key                  = "${local.global.env}/${path_relative_to_include()}/terraform.tfstate"

  }
}