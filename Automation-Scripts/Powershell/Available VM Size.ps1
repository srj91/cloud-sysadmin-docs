

#Login-AzureRmAccount

Select-AzureRmSubscription -Subscription "061c8f0d-c351-4d8e-8bc4-8bb9cf3e1040"

#check if vm size is available in the location
$location="CentralIndia"
Get-AzureRmVMSize -Location $location | Out-File "C:\Region-sizes-available.txt"

#After confirming that size is available in region, make sure that it's available on the current cluster where the virtual machine resides.
$rgName="POC-RG"
$vmName="Webserver1"
Get-AzureRmVMSize -ResourceGroupName $rgName -VMName $vmName| Out-File "C:\VM-sizes-available-in-Cluster.txt" 
 
