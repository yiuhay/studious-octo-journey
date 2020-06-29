module "labels" {
  source      = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.16.0"
  
  tags = {
    "environment" = var.env
    "project"     = var.project
    "owner"       = var.owner
  }
}

resource "azurerm_network_interface" "nic_windows" {
  count               = var.instance_count
  name                = "${var.vm_prefix}-nic-${count.index}"
  location             = data.azurerm_virtual_network.vnet.location
  resource_group_name  = "${var.rg_prefix}-rg"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.snet_vm.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = module.labels.tags
}

resource "azurerm_virtual_machine" "windows" {
  count                 = var.instance_count
  name                  = "${var.vm_prefix}-vm-${count.index}"
  location             = data.azurerm_virtual_network.vnet.location
  resource_group_name  = "${var.rg_prefix}-rg"
  vm_size               = var.vm_size
  network_interface_ids = [element(azurerm_network_interface.nic_windows.*.id, count.index)]

  os_profile_windows_config {
    provision_vm_agent = true
    timezone           = "GMT Standard Time"
  }

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.vm_prefix}-os-${count.index}"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "StandardSSD_LRS"
    os_type           = "Windows"
  }

  os_profile {
    computer_name  = "${var.vm_prefix}-${count.index}"
    admin_username = "adminuser"
    admin_password = data.azurerm_key_vault_secret.winadmin.value
  }

  dynamic "storage_data_disk" {
    for_each = var.additional_data_disk ? ["data"] : []
    content {
      name              = "${var.vm_prefix}-data-${count.index}"
      managed_disk_type = var.data_disk_type
      create_option     = "Empty"
      lun               = 0
      disk_size_gb      = var.data_disk_size
      caching           = "ReadWrite"
    }
  }

  tags = module.labels.tags
}
