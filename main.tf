# Azure Provider source and version
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.85.0"
    }

    azapi = {
      source  = "azure/azapi"
      version = "=1.11.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

# Create a new resource group
resource "azurerm_resource_group" "dev_resource_group" {
  name     = "${var.prefix}_rg_1"
  location = var.location
}

# Create a new virtual network
resource "azurerm_virtual_network" "dev_virtual_network_1" {
  resource_group_name = azurerm_resource_group.dev_resource_group.name
  name                = "${var.prefix}_vn_1"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
}

# Create a new subnet
resource "azurerm_subnet" "dev_subnet_1" {
  name                 = "${var.prefix}_subnet_1"
  virtual_network_name = azurerm_virtual_network.dev_virtual_network_1.name
  resource_group_name  = azurerm_resource_group.dev_resource_group.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a new NSG to associate with Subnet
resource "azurerm_network_security_group" "dev_subnet_1_nsg_1" {
  name                = "${var.prefix}_nsg_1"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_resource_group.name
}

# Associate NSG and subnet
resource "azurerm_subnet_network_security_group_association" "dev_subnet_nsg_association_1" {
  network_security_group_id = azurerm_network_security_group.dev_subnet_1_nsg_1.id
  subnet_id                 = azurerm_subnet.dev_subnet_1.id
}

# Creates new network security rule to associate with NSG
resource "azurerm_network_security_rule" "dev_nsg_1_rule-1" {
  name                        = "${var.prefix}_nsg_1_rule_1"
  network_security_group_name = azurerm_network_security_group.dev_subnet_1_nsg_1.name
  resource_group_name         = azurerm_resource_group.dev_resource_group.name
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

# Create a public ip prefix to reserver 4 public ip addresses for the VMs
resource "azurerm_public_ip_prefix" "dev_public_ip_prefix_1" {
  name                = "${var.location}_public_ip_prefix"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_resource_group.name

  prefix_length = 31

  timeouts {
    delete = "1m"
  }

}

# Create a new public ip(1)
resource "azurerm_public_ip" "dev_public_ip_1" {
  name                = "${var.location}_public_ip_1"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.dev_resource_group.name
  allocation_method   = "Static"
  public_ip_prefix_id = azurerm_public_ip_prefix.dev_public_ip_prefix_1.id

  depends_on = [azurerm_public_ip_prefix.dev_public_ip_prefix_1]
}

# Create a new public ip(2)
resource "azurerm_public_ip" "dev_public_ip_2" {
  name                = "${var.location}_public_ip_2"
  location            = var.location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.dev_resource_group.name
  allocation_method   = "Static"
  public_ip_prefix_id = azurerm_public_ip_prefix.dev_public_ip_prefix_1.id

  depends_on = [azurerm_public_ip_prefix.dev_public_ip_prefix_1]
}



# Create 2 new NIC
resource "azurerm_network_interface" "dev_nics_1" {
  count               = 2
  name                = "${var.prefix}_dev_nic_${count.index}"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_resource_group.name


  ip_configuration {
    name                          = "nic_config"
    subnet_id                     = azurerm_subnet.dev_subnet_1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = count.index == 0 ? azurerm_public_ip.dev_public_ip_1.id : azurerm_public_ip.dev_public_ip_2.id
  }

  timeouts {
    delete = "2m"
  }

}



# Create 3 new virtual machines
resource "azurerm_linux_virtual_machine" "dev_vm_1" {
  count                 = 2
  name                  = "${var.prefix}_tf_az_vm_${count.index}"
  computer_name         = "devlinuxvm${count.index}"
  location              = var.location
  resource_group_name   = azurerm_resource_group.dev_resource_group.name
  availability_set_id   = azurerm_availability_set.dev_availability_set_1.id
  network_interface_ids = [azurerm_network_interface.dev_nics_1[count.index].id]
  admin_username        = var.username
  size                  = "Standard_B1s"

  os_disk {
    name                 = "devvmosdisk${count.index}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = var.username
    public_key = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
  }

}

# Create a new Availability Set
resource "azurerm_availability_set" "dev_availability_set_1" {
  name                         = "${var.prefix}_availability_set_1"
  location                     = var.location
  resource_group_name          = azurerm_resource_group.dev_resource_group.name
  platform_fault_domain_count  = 3
  platform_update_domain_count = 3
}
