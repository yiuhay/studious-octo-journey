remote_state {
  backend = "azurerm"
  config = {
    resource_group_name  = "ang-dev-secret-rg"
    storage_account_name = "angdevst"
    container_name       = "ang-dev-container"
    key                  = "dev/${path_relative_to_include()}/terraform.tfstate"

  }
}