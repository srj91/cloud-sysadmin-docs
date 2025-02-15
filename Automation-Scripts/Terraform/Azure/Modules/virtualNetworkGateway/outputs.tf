output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "vnet_name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet_name" {
  description = "The name of the regular subnet"
  value       = azurerm_subnet.snet.name
}

output "gateway_subnet_name" {
  description = "The name of the gateway subnet"
  value       = azurerm_subnet.gw_snet.name
}

output "public_ip_name" {
  description = "The name of the public IP for the gateway"
  value       = azurerm_public_ip.gw_pip.name
}

output "virtual_network_gateway_name" {
  description = "The name of the virtual network gateway"
  value       = azurerm_virtual_network_gateway.vng.name
}

output "local_network_gateway_name" {
  description = "The name of the local network gateway"
  value       = azurerm_local_network_gateway.lng.name
}

output "vpn_connection_name" {
  description = "The name of the VPN connection"
  value       = azurerm_virtual_network_gateway_connection.connection01.name
}
