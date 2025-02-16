connect-AzureRmAccount

get-AzureRmSubscription

Select-AzureRmSubscription -subscriptionname "Subscription_Name"


$TemplateNSGRules=Get-AzureRmNetworkSecurityGroup -Name 'NSG_Name' -ResourceGroupName 'RG_Name' | Get-AzureRmNetworkSecurityRuleConfig

$NSG=New-AzureRmNetworkSecurityGroup -ResourceGroupName 'RG_Name_New' -Location 'Location_Name' -Name 'Riplica_NSG_Name'

foreach ($rule in $TemplateNSGRules) 
{
    $NSG | Add-AzureRmNetworkSecurityRuleConfig -Name $rule.Name -Direction $rule.Direction -Priority $rule.Priority -Access $rule.Access -SourceAddressPrefix $rule.SourceAddressPrefix -SourcePortRange $rule.SourcePortRange -DestinationAddressPrefix $rule.DestinationAddressPrefix -DestinationPortRange $rule.DestinationPortRange -Protocol $rule.Protocol
    $NSG | Set-AzureRmNetworkSecurityGroup
}


