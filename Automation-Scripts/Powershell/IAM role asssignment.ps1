New-AzureRmRoleDefinition -InputFile "C:\Users\Gulab\OneDrive - G7 CR Technologies India Pvt Ltd\Text\Azure Scripts\IAMRole.json" 



#$sub = Select-AzureRmSubscription -SubscriptionName "Gulab-VS-MPN"

$IMVMAccess = "Subex_VMAccess"
$IMVMAccessBackup = "Subex_VMAccessBackup"
$SignInName = "gulabpasha_gmail.com#EXT#@gulabpashag7cr.onmicrosoft.com"
$VMName = "Subex-LinuxVHDImages"


$IAMS = Get-AzureRmRoleAssignment -SignInName $SignInName -RoleDefinitionName $IMVMAccess


Foreach ($IAM in $IAMS)

{

If ($IAM.Scope.split('/')[-1] -eq $VMName)

{

Write-Output "If Condition"


Remove-AzureRmRoleAssignment -InputObject $IAM 


$Resource = Get-AzureRmResource -ResourceType "Microsoft.Compute/virtualMachines" -Name "$VMName"

New-AzureRmRoleAssignment -SignInName $SignInName `
                            -RoleDefinitionName $IMVMAccessBackup `
                            -ResourceGroupName $Resource.ResourceGroupName `
                            -ResourceName $Resource.Name -ResourceType $Resource.ResourceType

}


} 

