$usercred = Get-Credential
 
Connect-AzAccount -Credential $usercred
$Connection16 = "Jarvis-Hexaware-New-VPN-Connection"
$GWName1 = "Jarvis-Gateway"
$LNGName6 = "Jarvis-Hexaware-LNG"
$RG1 = "Network-RG"
$Location1 = "Southeast Asia"
 
$vnet1gw = Get-AzVirtualNetworkGateway -Name $GWName1 -ResourceGroupName $RG1
$lng6 = Get-AzLocalNetworkGateway -Name $LNGName6 -ResourceGroupName $RG1
$ipsecpolicy6 = New-AzIpsecPolicy -IkeEncryption "AES256" -IkeIntegrity "SHA256" -DhGroup "DHGroup2" -IpsecEncryption "AES256" -IpsecIntegrity "SHA256" -PfsGroup "None" -SALifeTimeSeconds 3600 -SADataSizeKilobytes 102400000
New-AzVirtualNetworkGatewayConnection -Name $Connection16 -ResourceGroupName $RG1 -VirtualNetworkGateway1 $vnet1gw -LocalNetworkGateway2 $lng6 -Location $Location1 -ConnectionType IPsec -IpsecPolicies $ipsecpolicy6 -SharedKey "staquhexagatepass123"
 
----------------------------------------------------------------------------------
 
$ipsecPolicy = New-AzureRmIpsecPolicy -SALifeTimeSeconds "27000" -IpsecEncryption "AES256" -IpsecIntegrity "SHA256“ -IkeEncryption "AES256" -IkeIntegrity "SHA256" -DhGroup "DHGroup2" -PfsGroup "None" -SADataSizeKilobytes 102400000
Set-AzureRmVirtualNetworkGatewayConnection -VirtualNetworkGatewayConnection $Connection -IpsecPolicies $ipsecpolicy -UsePolicyBasedTrafficSelectors $True