###################### Comman Variable Values #################################

azure_region  = "eastus"
customer_name = "bigrock"
tags = {
  APT-Dept    = "430"
  APT-Product = "2270"
}

###################### Address space for the Vnet & Snet ######################

vnet_address_space      = ["10.0.0.0/16"]
subnet_address_prefixes = ["10.0.1.0/24"]

###################### NSG Rules ##############################################

allow_avd_ip          = ["192.168.1.0/24"]
allow_dc              = ["10.0.0.4/32"]
blocked_malicious_ips = ["10.0.0.5/32"]
allow_adself_server   = ["10.0.0.6/32"]
allow_nessus_azure_ip = ["10.0.0.7/32"]

###################### VM configurations ######################################
vm_size        = "Standard_DS1_v2"
admin_username = "adminuser"
admin_password = "P@ssw0rd1234" # should not be hardcoded in configuration
### values Should not be changes 
image_publisher = "MicrosoftWindowsServer"
image_offer     = "WindowsServer"
image_sku       = "2019-Datacenter"
image_version   = "latest"

###################### Managed Disk configurations ############################

disk_size_gb         = 512
storage_account_type = "Premium_LRS"
disk_lun             = 0
disk_caching         = "ReadWrite"

# Resource Group Name (referenced from the network module outputs)
#resource_group_name = module.resourcegroup.resource_group_name
