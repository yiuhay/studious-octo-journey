provider "azurerm" {
  version         = "=2.6.0"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

terraform {
  required_version = "~> 0.12.0"
}

#
# Networking
#
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.resource_suffix}"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
    name                = "vnet-${var.resource_suffix}"
    address_space       = [var.vnet_cidr]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = var.tags
}

resource "azurerm_subnet" "snet_bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.bastion_cidr
}

resource "azurerm_subnet" "snet_internal" {
  name                 = "snet-internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.internal_cidr
}

#
# vm
#
resource "azurerm_network_interface" "nic_ubuntu" {
  name                = "nic-ubuntu-${var.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "nic_windows" {
  name                = "nic-windows-${var.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet_internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "ubuntu" {
  name                = "vm-ubuntu-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B1ls"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic_ubuntu.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("${var.pub_key}")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "windows" {
  name                = "vm-${var.resource_suffix}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = var.win_admin
  network_interface_ids = [
    azurerm_network_interface.nic_windows.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

#
# bastion
#
resource "azurerm_public_ip" "pip_bastion" {
  name                = "pip-bastion-${var.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bastion-${var.resource_suffix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.snet_bastion.id
    public_ip_address_id = azurerm_public_ip.pip_bastion.id
  }

  tags = var.tags
}

#
# bastion nsg
#
resource "azurerm_network_security_group" "nsg_bastion" {
  name                = "nsg-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
  resource_group_name         = azurerm_resource_group.rg.name
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
  resource_group_name         = azurerm_resource_group.rg.name
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
  resource_group_name         = azurerm_resource_group.rg.name
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
  resource_group_name         = azurerm_resource_group.rg.name
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
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_bastion.name
}

resource "azurerm_subnet_network_security_group_association" "snet_bastion_assoc" {
  subnet_id                 = azurerm_subnet.snet_bastion.id
  network_security_group_id = azurerm_network_security_group.nsg_bastion.id

  depends_on = [
    azurerm_network_security_group.nsg_bastion,
    azurerm_network_security_rule.ingress_bastion_any,
    azurerm_network_security_rule.ingress_bastion_gm,
    azurerm_network_security_rule.egress_bastion_azure,
    azurerm_network_security_rule.egress_bastion_rdp,
    azurerm_network_security_rule.egress_bastion_ssh,
  ]
}

#
# internal nsg
#
resource "azurerm_network_security_group" "nsg_internal" {
  name                = "nsg-internal"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
  resource_group_name         = azurerm_resource_group.rg.name
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
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_internal.name
}

resource "azurerm_subnet_network_security_group_association" "snet_internal_assoc" {
  subnet_id                 = azurerm_subnet.snet_internal.id
  network_security_group_id = azurerm_network_security_group.nsg_internal.id
}
