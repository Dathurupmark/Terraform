terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.41.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

subscription_id   = "28efb35e-36f5-4d32-af03-8705393002d5"
client_id         = "9a3dcc4f-6b5d-4e8d-a08a-9146c03512ee"
client_secret     = "lqK8Q~xdZlSzIaHrkA6kI3nK0n_IVR9GrPC1Pc9u"
tenant_id         = "5f23839b-590d-4195-aa24-be60b7da14e1"
}
resource "azurerm_resource_group" "rsglocation" {
  name     = "${var.rsgname}"
  location = "${var.rsglocation}"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-10"
  location            = "${azurerm_resource_group.rsg.location}"
  resource_group_name = "${azurerm_resource_group.rsg.name}"
  address_space       = ["${var.vnet_cidr_prefix}"]
 }

  resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rsg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  location            = azurerm_resource_group.eastus.location
  resource_group_name = azurerm_resource_group.rsg.name
}

# NOTE: this allows RDP from any network
resource "azurerm_network_security_group" "rdp" {
    name                       = "rdp"
    resource_group_name        = "rsg"
    network_security_group     = "nsg"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

 resource "azurerm_subnet_network_security_group_association" "nsg1_subnet1_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
 }

 resource "azurerm_network_interface" "nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rsg.location
  resource_group_name = azurerm_resource_group.rsg.name
 
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

resource "azurerm_windows_virtual_machine" "main" {
  name                = "${var.prefix}-vmt01"
  resource_group_name = azurerm_resource_group.rsg.name
  location            = azurerm_resource_group.rsg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = "password"
  network_interface_ids = [ azurerm_network_interface.nic.id ]
}

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-R2-Datacenter"
    version   = "latest"
  }
}
