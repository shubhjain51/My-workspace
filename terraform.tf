1- Terraform

terraform {
  required_providers {
    azurerm = {
      source= "hashicorp/azure"
      version = "3.87.0"
    }
  }
}

provider "azurerm" {
  region= "ap-south-1"
  alias= "mumbai"
}

resource "azure_resource_group" "example" {
  name= "subhanshu-rg"
  location= "ap-south-1"
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "main" {
  name= "shubhanshu"
  location= azurerm_resource_group.example.location
  resource_group = azurerm_resource_group.example.name
  network_interface_id= [azurerm_network_interface.main.id]
  vm_size= "Standard_DS1_V2"

    storage_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }

  # Dyanmic Block in terraform

  dynamic "setting" {
    for_each= var.setting != null ? var.setting : {}
    content{
      name= setting.value.name   # or  setting.value["name"]
      namespace= setting.value.namespace
      value= setting.value.value
    }
  }
}
}
