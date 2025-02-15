provider "azurerm" {
  features {}
}

# Generate a random 3-digit number
resource "random_integer" "random_3digit" {
  min = 100
  max = 999
}

# Create Public IP Address
resource "azurerm_public_ip" "public_ip" {
  name                = "PIP-${random_integer.random_3digit.result}-${var.customer_name}"
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  allocation_method   = "Dynamic"
  tags                = var.tags
}

# Create the Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.azure_region}-apprise-${var.customer_name}"
  address_space       = var.vnet_address_space
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create the Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "snet-${var.azure_region}-apprise-${var.customer_name}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefixes
}

# Create the Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.customer_name}-${random_integer.random_3digit.result}"
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create NSG Rules
resource "azurerm_network_security_rule" "allow_avd_ip" {
  name                        = "Allow_AVD_IP"
  priority                    = 1040
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = var.allow_avd_ip
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_dc" {
  name                        = "Allow_DC"
  priority                    = 1050
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.allow_dc
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "blocked_malicious_ips" {
  name                        = "Blocked_Malicious_IPs"
  priority                    = 3888
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.blocked_malicious_ips
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_adself_server" {
  name                        = "Allow_ADself_Server_IP"
  priority                    = 1060
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.allow_adself_server
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

resource "azurerm_network_security_rule" "allow_nessus_azure_ip" {
  name                        = "Allow_Nessus_Azure_IP"
  priority                    = 1070
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "TCP"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = var.allow_nessus_azure_ip
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = var.resource_group_name
}

# Create Network Interface Card (NIC)
resource "azurerm_network_interface" "nic" {
  name                = "nic-${random_integer.random_3digit.result}-${var.customer_name}"
  location            = var.azure_region
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}
# Correct way to associate NSG in version 2.46.1
# Associate the NSG with the NIC
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


