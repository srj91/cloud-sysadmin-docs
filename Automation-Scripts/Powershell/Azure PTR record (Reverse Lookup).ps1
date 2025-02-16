Kindly find the below PS which helps to create reverse lookup for your DNS PTR (CName)

#Login-AzureRmAccount

Select-AzureRmSubscription -SubscriptionName "SMTP Subscription"

$RGName = "Alice8-SMTP-ServerRG"
$PIPName = "SMTPServer-PIP"
$Location = "Central India"
$FQDN = "alice.peopledomain.in"
$AzureDNS = "peoplework-alicesmtp"

$PIP = Get-AzureRmPublicIpAddress -Name $PIPName -ResourceGroupName $RGname

$PIP

New-AzureRmPublicIpAddress -ReverseFqdn $FQDN -Name $PIPName -ResourceGroupName $RGName -Location $Location -AllocationMethod Static -DomainNameLabel $AzureDNS -Force 
