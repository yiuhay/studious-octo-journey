terraform {
  required_version = ">= 0.12"
}

resource "azurerm_network_interface" "nic_ubuntu" {
  name                = "${var.resource_prefix}-nic-ubuntu"
  resource_group_name = var.rg_name
  location            = var.rg_location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.snet_internal_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "ubuntu" {
  name                = "${var.resource_prefix}-vm-ubuntu"
  resource_group_name = var.rg_name
  location            = var.rg_location
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