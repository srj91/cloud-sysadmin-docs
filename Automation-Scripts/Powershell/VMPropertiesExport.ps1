   

Select-AzureRmSubscription -SubscriptionName "Emil"

$VMS = Get-AzureRmVM
$results = @()
$Resources
$file = "C:\Container-POC.csv"

Foreach ($VM in $VMS)

{

$SplitNicArmId = $VM.NetworkProfile.NetworkInterfaces[0].Id.split("/")
$NICRG = $SplitNicArmId[4]
$NICname = $SplitNicArmId[-1]
$NIC = Get-AzureRMNetworkInterface -ResourceGroupName $NICRG -Name $NICname

$SplitPIP = $NIC.IpConfigurations[0].PublicIpAddressText.Split()[-3].Split("""")
$Split = $SplitPIP.split("/")
$PIPRG = $Split[-6]
$PIPName = $Split[-2]

$pip = Get-AzureRmPublicIpAddress -Name $PIPName -ResourceGroupName $PIPRG
$details  = @{ 

'ResourceGroupName' = $VM.ResourceGroupName
'VMName' = $VM.Name
'VMSize' = $VM.HardwareProfile.VmSize
'VM_OSType' = $VM.StorageProfile.OsDisk.OsType
'VM_OSDisk_Size' = $VM.StorageProfile.OsDisk.DiskSizeGB
'VM_Datadisk1_Size' = $vm.StorageProfile.DataDisks[0].DiskSizeGB
'VM_Datadisk2_Size' = $vm.StorageProfile.DataDisks[1].DiskSizeGB
'VM_PrivateIP' = $NIC.IpConfigurations.PrivateIpAddress
'VM_PublicIP' = $pip.IpAddress
 }

$results += New-Object PSObject -Property $details

}

$results | Select "ResourceGroupName","VMName","VMSize","VM_OSType","VM_OSDisk_Size","VM_Datadisk1_Size","VM_Datadisk2_Size","VM_PrivateIP","VM_PublicIP" | Export-Csv -Path $file






























