
## Creating Resource-Group and Vnet and 

New-AzResourceGroup -Name Atyati-RG -Location SouthEastAsia
New-AzResourceGroup -Name crossdomain-RG -Location EastUs

## Specify Subnet details

$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name app-SNet -AddressPrefix "10.0.2.0/24"
$subnetConfig = New-AzVirtualNetworkSubnetConfig -Name Web-SNet -AddressPrefix "192.168.2.0/24"

## Create Virtual network and subnet

$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName Atyati-RG -Location SouthEastAsia -Name Atyati-VNet  -AddressPrefix "10.0.0.0/16" -Subnet $subnetConfig
$VirtualNetwork = New-AzVirtualNetwork -ResourceGroupName crossdomain-RG -Location EastUs -Name crossdomain-VNet  -AddressPrefix "192.168.0.0/16" -Subnet $subnetConfig


## create new VM and run job in background

New-AzVM -ResourceGroupName Atyati-RG -Location SouthEastAsia -VirtualNetworkName Atyati-VNet -SubnetName app-SNet -Name TestVM -AsJob


## create new VM and run job in background

New-AzVM -ResourceGroupName Atyati-RG -Location SouthEastAsia -VirtualNetworkName Atyati-VNet -SubnetName app-SNet -Name TroubleShootVM -AsJob
 

## Get Public IPaddress of VM

Get-AzPublicIpAddress -Name TroubleShootVM -ResourceGroupName Atyati-RG | Select IpAddress

## Connect using CMD

C:\Windows\system32>mstsc /v:52.230.67.178


## Allowing ICMP Rule

New-NetFirewallRule –DisplayName "Allow ICMPv4-In" –Protocol ICMPv4

## Passing Vnet value as variable

$virtualnetwork1=Get-AzVirtualNetwork -Name Atyati-Vnet -ResourceGroupName Atyati-RG

$virtualnetwork2=Get-AzVirtualNetwork -Name crossdomain-Vnet -ResourceGroupName crossdomain-RG


## Peering both Vnet Vice-Versa

Add-AzVirtualNetworkPeering -Name Atyati-vnet-crossdomain-vnet -VirtualNetwork $virtualnetwork1 -RemoteVirtualNetworkId $virtualnetwork2.Id

Add-AzVirtualNetworkPeering -Name crossdomain-vnet-Atyati-vnet -VirtualNetwork $virtualnetwork2 -RemoteVirtualNetworkId $virtualnetwork1.Id


## Getting peering information from both side

Get-AzVirtualNetworkPeering -ResourceGroupName Atyati-RG -VirtualNetworkName Atyati-Vnet | Select PeeringState

Get-AzVirtualNetworkPeering -ResourceGroupName Atyati-RG -VirtualNetworkName Atyati-Vnet | Select PeeringState

