module "labels" {
  source = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  
  tags = {
    "environment" = var.env
    "project"     = var.project
    "owner"       = var.owner
  }
}

resource "azurerm_subnet" "snet_vgw" {
  name                 = "GatewaySubnet"
  resource_group_name  = "${var.rg_prefix}-rg"
  virtual_network_name = var.vnet_prefix
  address_prefix       = var.cidr_vgw
}

resource "azurerm_public_ip" "pip_vgw" {
  name                 = "${var.vnet_prefix}-pip-vgw"
  location             = data.azurerm_virtual_network.vnet.location
  resource_group_name  = "${var.rg_prefix}-rg"
  allocation_method    = "Static"
  sku                  = "Standard"

  tags = module.labels.tags
}

resource "azurerm_virtual_network_gateway" "vgw" {
  name                 = "${var.vnet_prefix}-vgw"
  location             = data.azurerm_virtual_network.vnet.location
  resource_group_name  = "${var.rg_prefix}-rg"

  type                 = "Vpn"
  vpn_type             = "RouteBased"

  active_active        = false
  enable_bgp           = false
  sku                  = "VpnGw1"

  ip_configuration {
    subnet_id            = azurerm_subnet.snet_vgw.id
    public_ip_address_id = azurerm_public_ip.pip_vgw.id
  }

  tags = module.labels.tags
}

resource "azurerm_local_network_gateway" "lgw" {
  name                 = "${var.vnet_prefix}-lgw"
  location             = data.azurerm_virtual_network.vnet.location
  resource_group_name  = "${var.rg_prefix}-rg"

  gateway_address      = data.azurerm_key_vault_secret.onprem_public.value
  address_space        = var.onprem_private

  tags = module.labels.tags
}

resource "azurerm_virtual_network_gateway_connection" "cn" {
  name                       = "${var.vnet_prefix}-lgw-to-${var.vnet_prefix}-vgw-cn"
  location                   = data.azurerm_virtual_network.vnet.location
  resource_group_name        = "${var.rg_prefix}-rg"

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vgw.id
  local_network_gateway_id   = azurerm_local_network_gateway.lgw.id

  shared_key                 = data.azurerm_key_vault_secret.vpn_psk.value

  ipsec_policy {
    dh_group         = var.dh_group
    ike_encryption   = var.ike_encryption
    ike_integrity    = var.ike_integrity

    ipsec_encryption = var.ipsec_encryption
    ipsec_integrity  = var.ipsec_integrity
    pfs_group        = var.pfs_group
  }

  tags = module.labels.tags
}