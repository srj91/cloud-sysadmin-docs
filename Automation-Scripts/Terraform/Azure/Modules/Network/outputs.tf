output "virtual_network_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.vnet.name
}

output "virtual_network_id" {
  description = "The ID of the virtual network."
  value       = azurerm_virtual_network.vnet.id
}

output "subnet_name" {
  description = "The name of the subnet."
  value       = azurerm_subnet.subnet.name
}

output "subnet_id" {
  description = "The ID of the subnet."
  value       = azurerm_subnet.subnet.id
}

output "network_security_group_name" {
  description = "The name of the network security group."
  value       = azurerm_network_security_group.nsg.name
}

output "network_security_group_id" {
  description = "The ID of the network security group."
  value       = azurerm_network_security_group.nsg.id
}

output "nsg_rules" {
  description = "List of network security group rules"
  value = [
    azurerm_network_security_rule.allow_avd_ip.name,
    azurerm_network_security_rule.allow_dc.name,
    azurerm_network_security_rule.blocked_malicious_ips.name,  # Updated name
    azurerm_network_security_rule.allow_adself_server.name,
    azurerm_network_security_rule.allow_nessus_azure_ip.name,
  ]
}

output "public_ip" {
  description = "The public IP address of the VM."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "nic_id" {
  description = "The ID of the network interface."
  value       = azurerm_network_interface.nic.id
}