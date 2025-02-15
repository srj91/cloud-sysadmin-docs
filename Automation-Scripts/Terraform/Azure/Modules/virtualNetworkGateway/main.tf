######################### register Providers ########################
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.46.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {}

resource "random_integer" "random_3digit" {
  min = 100
  max = 999
}

###########################################################
#                   Resource Group                        #
###########################################################

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.azure_region}-prd-apprise-${var.customer_name}"
  location = var.azure_region
}

###########################################################
#              Virtual Network and Subnet                 #
###########################################################

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.azure_region}-prd-apprise-${var.customer_name}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "snet" {
  name                 = "snet-${var.azure_region}-prd-apprise-${var.customer_name}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.snet_address_prefix]
}

resource "azurerm_subnet" "gw_snet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.gw_snet_address_prefix]
}

resource "azurerm_public_ip" "gw_pip" {
  name                = "gw-pip-${var.azure_region}-prd-apprise-${var.customer_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

###########################################################
#     Virtual Network Gateway and Local Network Gateway   #
###########################################################

resource "azurerm_virtual_network_gateway" "vng" {
  name                = "vng-${random_integer.random_3digit.result}-${var.customer_name}"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.rg.name
  type                = "Vpn"
  vpn_type            = "RouteBased"
  active_active       = false
  enable_bgp          = false
  sku                 = "VpnGw2"
  depends_on          = [azurerm_resource_group.rg]

  ip_configuration {
    name                 = "gw-ip-config"
    public_ip_address_id = azurerm_public_ip.gw_pip.id
    subnet_id            = azurerm_subnet.gw_snet.id
  }
}

resource "azurerm_local_network_gateway" "lng" {
  name                = "lng-${var.azure_region}-prd-apprise-${var.customer_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.azure_region
  gateway_address     = var.lng_ip_address
  address_space       = var.lng_address_prefixes
}

###########################################################
#                Connection Creation                      #
###########################################################

resource "azurerm_virtual_network_gateway_connection" "connection01" {
  name                       = "connection01-${random_integer.random_3digit.result}-${var.azure_region}-prd-apprise-${var.customer_name}"
  location                   = var.azure_region
  resource_group_name        = azurerm_resource_group.rg.name
  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vng.id
  local_network_gateway_id   = azurerm_local_network_gateway.lng.id
  shared_key                 = var.shared_key
}
