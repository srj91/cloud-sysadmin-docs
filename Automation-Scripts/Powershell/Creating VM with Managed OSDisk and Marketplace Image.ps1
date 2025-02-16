Select-AzureRmSubscription -SubscriptionName ""

$RGName = ""       
$VMName = "" 
$VMLocation = ""
$VMSize = ""
$DiskName = ""
$VNetName = ""
$SubnetName = ""
$DNSName = $VMName.ToLower() 




    $VNet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RGName

    $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name $SubnetName -VirtualNetwork $VNet

    $pip = New-AzureRmPublicIpAddress -Name "$VMName-PIP" -ResourceGroupName $RGName -Location $VMLocation `
    -AllocationMethod Dynamic -DomainNameLabel $DNSName -Force 

    $nsg = New-AzureRmNetworkSecurityGroup -Name “$VMName-NSG” -ResourceGroupName "$RGName" -Location $VMLocation
    
    $nic = New-AzureRmNetworkInterface -Name "$VMName-NIC" -ResourceGroupName $RGName -Location $VMLocation `
    -SubnetId $subnet.Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.Id -Force
               
    $disk = Get-AzureRmDisk -ResourceGroupName $RGName -DiskName $DiskName
       
    $vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

    $vm = Set-AzureRmVMPlan -VM $vm -Name "4-4" -Product "wordpress" -Publisher "bitnami"
      
    $vm = Set-AzureRmVMOSDisk -VM $vm -Name "$VMName-OSDisk" -Linux -CreateOption "Attach" -ManagedDiskId $disk.Id      
   
    $vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id
        
    New-AzureRmVM -VM $vm -ResourceGroupName $RGName -Location $VMLocation
