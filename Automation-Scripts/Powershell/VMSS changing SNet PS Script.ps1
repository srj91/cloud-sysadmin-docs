#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionId "efdb1157-e745-4b77-88e1-1f3df131c464"

$RGName = "GulabVMSS"
$VMSSName = "GulabVMSS"
$Location = "southeastasia"
$VNetName = "GulabVMSS-VNet"
$Subnet = "GulabVMSS-SNet2"

$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RGName
$snet = Get-AzureRmVirtualNetworkSubnetConfig -Name $Subnet -VirtualNetwork $vnet

$snetid = $snet.Id

$VMSS = Get-AzureRmVmss -ResourceGroupName $RGName -VMScaleSetName $VMSSName

$vmss.VirtualMachineProfile.NetworkProfile.NetworkInterfaceConfigurations.IpConfigurations[0].Subnet = $snetid


Update-AzureRmVmss -ResourceGroupName $RGName -VMScaleSetName $VMSSName -VirtualMachineScaleSet $VMSS

Update-AzureRmVmssInstance -ResourceGroupName $RGName -VMScaleSetName $VMSSName -InstanceId "0","3" 

