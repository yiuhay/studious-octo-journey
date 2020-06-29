data "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_prefix}-vnet"
  resource_group_name = "${var.rg_prefix}-rg"
}

data "azurerm_subnet" "snet_vgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${var.rg_prefix}-rg"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
}

data "azurerm_key_vault" "kv" {
  name                = "${var.rg_prefix}-kv"
  resource_group_name = "${var.rg_prefix}-secret-rg"
}

data "azurerm_key_vault_secret" "onprem_public" {
  name         = var.onprem_public
  key_vault_id = data.azurerm_key_vault.kv.id
}

data "azurerm_key_vault_secret" "vpn_psk" {
  name         = var.vpn_psk
  key_vault_id = data.azurerm_key_vault.kv.id
} 