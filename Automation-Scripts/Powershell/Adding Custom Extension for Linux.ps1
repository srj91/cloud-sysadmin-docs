Update Script to add CustomExtension.

#Login-AzureRmAccount

$Subscriptions = Get-AzureRmSubscription


$ExtensionName = 'CustomScriptForLinux'
$Publisher = 'Microsoft.OSTCExtensions'
$Version = '1.4'

$PublicConf = '{
    "fileUris": ["https://subexlinuximagesstg.blob.core.windows.net/script/script.sh"],
    "commandToExecute": "sh script.sh"
}'
$PrivateConf = '{
    "storageAccountName": "subexlinuximagesstg",
    "storageAccountKey": "L1cTjXGb6aMtkVrPCkIGmCWCIGXqSreCYOaQ37g2akb7R+H6rLrABynNZpcahYJo5XAmakYDL3oIVYz3NtAJNA=="
}'



Foreach ($Subscription in $Subscriptions)

    {

        Select-AzureRmSubscription -SubscriptionName $Subscription.Name

        $VMS = Get-AzureRMVM

            Foreach ($VM in $VMS)

                {

                             
                    if ($VM.StorageProfile.OsDisk.OsType -eq "Linux")

                        {
                            $Subscription.Name
                            $VM.ResourceGroupName
                            $VM.Name
                            $VM.StorageProfile.OsDisk.OsType

                            $RGName = $VM.ResourceGroupName
                            $VmName = $VM.Name
                            $Location = $VM.Location

                            Set-AzureRmVMExtension -ResourceGroupName $RGName -VMName $VmName -Location $Location `
                            -Name $ExtensionName -Publisher $Publisher -ExtensionType $ExtensionName -TypeHandlerVersion $Version `
                            -Settingstring $PublicConf -ProtectedSettingString $PrivateConf

                        }

                }

    } 
