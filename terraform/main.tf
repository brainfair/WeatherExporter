variable "PW" {
  type = string
}

terraform {
  backend "azurerm" {
    resource_group_name  = "weathertfstates"
    storage_account_name = "weathertf"
    container_name       = "tfstatedevops"
    key                  = "tfstatedevops.tfstate"
  }
}

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you're using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}

data "azurerm_client_config" "current" {}

#Create Resource Group
resource "azurerm_resource_group" "weather" {
  name     = "weather"
  location = "westeurope"
}

#Create Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "weather-vnet"
  address_space       = ["192.168.0.0/16"]
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.weather.name
}

# Create Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.weather.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = "192.168.0.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
  name                = "WeatherPublicIP"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.weather.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "WeatherNetworkSecurityGroup"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.weather.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "WeatherNIC"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.weather.name

  ip_configuration {
    name                          = "WeatherNicConfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nsgassociation" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


# Create virtual machine
resource "azurerm_linux_virtual_machine" "tfvm" {
  name                  = "WeatherDash"
  location              = "westeurope"
  resource_group_name   = azurerm_resource_group.weather.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "20.04-LTS"
    version   = "latest"
  }

  computer_name                   = "weatherdash"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.PW
  }
}
