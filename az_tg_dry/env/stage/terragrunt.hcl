remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "ang-state-rg"
    storage_account_name = "angtfacc"
    container_name       = "angtfcon"
    key                  = "stage/${path_relative_to_include()}/terraform.tfstate"

  }
}