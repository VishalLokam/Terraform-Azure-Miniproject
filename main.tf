# Azure Provider source and version
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
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
resource "azurerm_virtual_network" "dev_virtual_machine" {
  resource_group_name = azurerm_resource_group.dev_resource_group.name
  name = "${var.prefix}_vn_1"
  address_space = [ "10.0.0.0/16" ]
  location = var.location
}

