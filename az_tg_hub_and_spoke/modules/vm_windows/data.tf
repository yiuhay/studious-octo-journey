data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_prefix}-vnet"
  resource_group_name = "${var.rg_prefix}-rg"
}

data "azurerm_subnet" "snet_vm" {
  name                 = var.snet_name
  resource_group_name  = "${var.rg_prefix}-rg"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_key_vault" "kv" {
  name                = "${var.resource_prefix}-kv"
  resource_group_name = "${var.resource_prefix}-secret-rg"
}

data "azurerm_key_vault_secret" "winadmin" {
  name         = var.win_admin_password
  key_vault_id = data.azurerm_key_vault.kv.id
}