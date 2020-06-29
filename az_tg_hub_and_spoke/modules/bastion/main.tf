module "labels" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  
  tags = {
    "environment" = var.env
    "project"     = var.project
    "owner"       = var.owner
  }
}

resource "azurerm_public_ip" "pip_bastion" {
  name                = "${var.resource_prefix}-pip-bastion"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = "${var.rg_prefix}-rg"
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = module.labels.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                 = "${var.resource_prefix}-bastion"
  location             = data.azurerm_virtual_network.vnet.location
  resource_group_name  = "${var.rg_prefix}-rg"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = data.azurerm_subnet.snet_bastion.id
    public_ip_address_id = azurerm_public_ip.pip_bastion.id
  }

  tags = module.labels.tags
}

resource "azurerm_network_security_group" "nsg_bastion" {
  name                 = "nsg-bastion"
  location             = data.azurerm_virtual_network.vnet.location
  resource_group_name  = "${var.rg_prefix}-rg"

  tags = module.labels.tags
}

resource "azurerm_subnet_network_security_group_association" "snet_bastion_assoc" {
  subnet_id                 = data.azurerm_subnet.snet_bastion.id
  network_security_group_id = azurerm_network_security_group.nsg_bastion.id
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
  resource_group_name         = "${var.rg_prefix}-rg"
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
  resource_group_name         = "${var.rg_prefix}-rg"
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
  resource_group_name         = "${var.rg_prefix}-rg"
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
  resource_group_name         = "${var.rg_prefix}-rg"
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
  resource_group_name         = "${var.rg_prefix}-rg"
  network_security_group_name = azurerm_network_security_group.nsg_bastion.name
}
