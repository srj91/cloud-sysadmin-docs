# variables.tf

variable "azure_region" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "customer_name" {
  description = "The name of the customer."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "subnet_address_prefixes" {
  description = "The address prefixes for the subnet."
  type        = list(string)
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "allow_avd_ip" {
  description = "The IP address prefix to allow for AVD."
  type        = string
}

variable "allow_dc" {
  description = "The IP address prefix to allow for DC."
  type        = string
}

variable "blocked_malicious_ips" {
  description = "The IP address prefix to block for malicious IPs."
  type        = string
}

variable "allow_adself_server" {
  description = "The IP address prefix to allow for AD self-server."
  type        = string
}

variable "allow_nessus_azure_ip" {
  description = "The IP address prefix to allow for Nessus Azure."
  type        = string
}

# variable "private_ip_address" {
#   description = "The static private IP address to assign to the NIC."
#   type        = string
# }
