# vnet
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  resource_group_name = var.rg_name
  location            = var.rg_location

  tags                = var.tags
}

# subnets
resource "azurerm_subnet" "snet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.bastion_cidr
}

resource "azurerm_subnet" "snet_internal" {
  name                 = "snet-internal"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.internal_cidr
}

# bastion
resource "azurerm_public_ip" "pip_bastion" {
  name                = "${var.resource_prefix}-pip-bastion"
  location            = var.rg_location
  resource_group_name = var.rg_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "${var.resource_prefix}-bastion"
  location            = var.rg_location
  resource_group_name = var.rg_name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.snet_bastion.id
    public_ip_address_id = azurerm_public_ip.pip_bastion.id
  }

  tags = var.tags
}

# bastion nsg
resource "azurerm_network_security_group" "nsg_bastion" {
  name                = "nsg-bastion"
  location            = var.rg_location
  resource_group_name = var.rg_name

  tags = var.tags
}

resource "azurerm_network_security_rule" "ingress_bastion_any" {
  name                        = "InboundFromAny"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion.name
}

resource "azurerm_network_security_rule" "ingress_bastion_gm" {
  name                        = "InboundFromGM"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["443",
                                 "4443",
                                ]
  source_address_prefix       = "GatewayManager"
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion.name
}

resource "azurerm_network_security_rule" "egress_bastion_azure" {
  name                        = "OutboundHTTPStoAzureCloud"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "AzureCloud"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion.name
}

resource "azurerm_network_security_rule" "egress_bastion_rdp" {
  name                        = "OutboundToVNET_RDP"
  priority                    = 110
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion.name
}

resource "azurerm_network_security_rule" "egress_bastion_ssh" {
  name                        = "OutboundToVNET_SSH"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_bastion.name
}

resource "azurerm_subnet_network_security_group_association" "snet_bastion_assoc" {
  subnet_id                 = azurerm_subnet.snet_bastion.id
  network_security_group_id = azurerm_network_security_group.nsg_bastion.id
}

# internal nsg
resource "azurerm_network_security_group" "nsg_internal" {
  name                = "nsg-internal"
  location            = var.rg_location
  resource_group_name = var.rg_name

  tags = var.tags
}

resource "azurerm_network_security_rule" "ingress_internal_ssh" {
  name                        = "InboundFromSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.bastion_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_internal.name
}

resource "azurerm_network_security_rule" "ingress_internal_rdp" {
  name                        = "InboundFromRDP"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = var.bastion_cidr
  destination_address_prefix  = "*"
  resource_group_name         = var.rg_name
  network_security_group_name = azurerm_network_security_group.nsg_internal.name
}

resource "azurerm_subnet_network_security_group_association" "snet_internal_assoc" {
  subnet_id                 = azurerm_subnet.snet_internal.id
  network_security_group_id = azurerm_network_security_group.nsg_internal.id
}