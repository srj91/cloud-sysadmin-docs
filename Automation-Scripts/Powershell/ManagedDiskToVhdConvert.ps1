
    
Login-AzureRmAccount
Select-AzureRmSubscription -SubscriptionName "Microsoft Azure Sponsorship"


$RGName = "r-d-server-RG-2" 
$DiskName = "r-d-server2-OSDisk-28042020"


$StorageAccount = "migratestorageserver2"
$STGKey = "dgosW21YW1kCyPLfhjf7Qhj14XMvRqqFB9Usp4jnjOPjJLRdwhfqBa3mJxHDnE7i479BUFQSK0vefgv/GKaYUA=="
$ContainerName = "migratecontainer"


$VHDName = "r-d-servermigrated.vhd"


$sas = Grant-AzureRmDiskAccess -ResourceGroupName $RGName -DiskName $DiskName -DurationInSecond 9600 -Access Read 
$destContext = New-AzureStorageContext –StorageAccountName $StorageAccount -StorageAccountKey $STGKey 
$blob1 = Start-AzureStorageBlobCopy -AbsoluteUri $sas.AccessSAS -DestContainer $ContainerName -DestContext $destContext -DestBlob $VHDName


## Retrieve the current status of the blob copy operation ###
$status = $blob1 | Get-AzureStorageBlobCopyState
  
### Print out status ### 
$status
  
### Loop until complete ###                                    
While($status.Status -eq "Pending"){
  $status = $blob1 | Get-AzureStorageBlobCopyState
  Start-Sleep 10
  ### Print out status ###
  $status
}



