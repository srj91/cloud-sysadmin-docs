variable "azure_region" {
  description = "The Azure region where resources will be created"
  type        = string
}

variable "customer_name" {
  description = "The customer name used to uniquely identify resources"
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network"
  type        = string
}

variable "snet_address_prefix" {
  description = "The address prefix for the regular subnet"
  type        = string
}

variable "gw_snet_address_prefix" {
  description = "The address prefix for the gateway subnet"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "lng_ip_address" {
  description = "The IP address of the local network gateway"
  type        = string
}

variable "lng_address_prefixes" {
  description = "The address prefixes of the local network gateway"
  type        = list(string)
}

variable "shared_key" {
  description = "The shared key for the VPN connection"
  type        = string
}
