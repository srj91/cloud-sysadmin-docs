#Login-AzureRmAccount


Select-AzureRmSubscription -SubscriptionName 'Visual Studio Enterprise – MPN'

$VMS = Import-Csv -LiteralPath 'C:\Users\Gulab\Desktop\FDP_18thJune 2019_ListofAttendees.csv'

$location = “SouthEast Asia”
  
#Run this to create a Vm from Windows image 
#$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName MicrosoftWindowsServer -Offer WindowsServer -Skus 2012-R2-Datacenter -Version latest
#Find all the available publishers
$pubName = Get-AzurermVMImagePublisher -Location $location | Out-GridView -Title "Select Publisher" -PassThru 

#Pick a specific offer
$offerName = Get-AzurermVMImageOffer -Location $location -Publisher $pubName.PublisherName | Out-GridView -Title "Select Offer" -PassThru 


#View the different SKUs
$skuname = Get-AzurermVMImageSku -Location $location -Publisher $pubName.PublisherName -Offer $offerName.Offer | Out-GridView -Title "Select Sku" -PassThru

#View the versions of a SKU
$image = Get-AzurermVMImage -Location $location -PublisherName $pubName.PublisherName -Offer $offerName.Offer -Skus $skuname.Skus | Out-GridView -Title "Select Version" -PassThru

#View detail of a specific version of the SKU




Foreach ($VM in $VMS)

{


$rgroup = $VM.RG
$vmname = $VM.VM
$vmSize = "Standard_D2_V2"
$computerName = $VM.VM
$osDiskName = $vmname + "-OSDisk"
$nic = $vmname + "-nic"
$vnetname= $vmname + "-vnet"
$subnetname =  $vmname + "-subnet"
$vnetAddressPrefix = "10.0.0.0/16"
$vnetSubnetAddressPrefix = "10.0.0.0/24"
$PublicIPName = $vmname + "-pip"
$nsgname = "$vmname-nsg"

New-AzureRmResourceGroup -Name $rgroup -Location $location

$subnet = New-AzureRmVirtualNetworkSubnetConfig -Name $subnetname -AddressPrefix $vnetSubnetAddressPrefix

$vnet = New-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $rgroup -Location $location -AddressPrefix $vnetAddressPrefix -Subnet $subnet

$pip = New-AzureRmPublicIpAddress -Name $PublicIPName -ResourceGroupName $rgroup -Location $location -AllocationMethod Dynamic

$nsgRuleRDP = New-AzureRMNetworkSecurityRuleConfig -Name SSH  -Protocol Tcp `
  -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * `
  -DestinationPortRange 22 -Access Allow

$nsg = New-AzureRMNetworkSecurityGroup -ResourceGroupName $rgroup -Location $location `
  -Name $nsgname -SecurityRules $nsgRuleRDP


$nic = New-AzureRmNetworkInterface -Name $nic -ResourceGroupName $rgroup -Location $location -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $pip.Id -NetworkSecurityGroupId $nsg.id


#Credentials or your VM
$adminUsername = $VM.username
$adminPassword = $VM.Password

$cred = New-Object PSCredential $adminUsername, ($adminPassword | ConvertTo-SecureString -AsPlainText -Force)

#Assign Virtual machine and image config
$vmconfig = New-AzureRmVMConfig -VMName $vmname -VMSize $vmSize

$vm = Set-AzureRmVMOperatingSystem -VM $vmconfig  -ComputerName $computerName -Credential $cred -Linux

$vm = Set-AzureRmVMSourceImage -VM $vm -PublisherName $image.PublisherName -Offer $image.Offer -Skus $image.Skus -Version $image.Version

#Add the NIC to the VM and set one of the NIC as primary

$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$vm.NetworkProfile.NetworkInterfaces.Item(0).Primary = $true


# 6. create the VM
New-AzureRmVM -ResourceGroupName $rgroup -Location $location -VM $vm



} 
