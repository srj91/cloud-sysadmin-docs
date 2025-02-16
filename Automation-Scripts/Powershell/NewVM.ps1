$vmName = 'powershellvm'
$vmSize = 'Standard_DS2_v2'
$resourceGroup = Get-AzResourceGroup -Name 'cognixia'
$location = $resourceGroup.Location
$availabilitySet = Get-AzAvailabilitySet -ResourceGroupName $resourceGroup.ResourceGroupName -Name 'avset'
$vnet = Get-AzVirtualNetwork -Name 'cognixia-vnet' -ResourceGroupName $resourceGroup.ResourceGroupName
$subnetid = (Get-AzVirtualNetworkSubnetConfig -Name 'default' -VirtualNetwork $vnet).Id
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroup.ResourceGroupName -Location $location -Name "$vmName-nsg"
$pip = New-AzPublicIpAddress -Name "$vmName-ip" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $location -AllocationMethod Dynamic 
$nic = New-AzNetworkInterface -Name "$($vmName)$(Get-Random)" -ResourceGroupName $resourceGroup.ResourceGroupName -Location $location -SubnetId $subnetid -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id
$adminUsername = 'Student'
$adminPassword = 'abc@123456789'
$adminCreds = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)
$publisherName = 'MicrosoftWindowsServer'
$offerName = 'WindowsServer'
$skuName = '2016-Datacenter'
$osDiskType = (Get-AzDisk -ResourceGroupName $resourceGroup.ResourceGroupName)[0].Sku.Name
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize -AvailabilitySetId $availabilitySet.Id
Add-AzVMNetworkInterface -VM $vmConfig -Id $nic.Id
Set-AzVMOperatingSystem -VM $vmConfig -Windows -ComputerName $vmName -Credential $adminCreds 
Set-AzVMSourceImage -VM $vmConfig -PublisherName $publisherName -Offer $offerName -Skus $skuName -Version 'latest'
Set-AzVMOSDisk -VM $vmConfig -Name "$($vmName)_OsDisk_1_$(Get-Random)" -StorageAccountType $osDiskType -CreateOption fromImage
Set-AzVMBootDiagnostic -VM $vmConfig -Disable
New-AzVM -ResourceGroupName $resourceGroup.ResourceGroupName -Location $location -VM $vmConfig
