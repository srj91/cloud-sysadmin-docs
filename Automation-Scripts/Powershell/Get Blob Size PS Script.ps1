$results = @()

$Output = "C:\Users\Gulab\Desktop\Output.csv"

$Subscriptions = Get-AzureRmSubscription

Foreach ($Subscription in $Subscriptions)

{

$SubscriptionName = $Subscription.Name

Select-AzureRmSubscription -SubscriptionName $SubscriptionName

Write-Output "Subscription Name = $SubscriptionName"


$STGS = Get-AzureRmStorageAccount

Foreach ($STG in $STGS)

{

$StorageAccount = Get-AzureRmStorageAccount -Name $STG.StorageAccountName -ResourceGroupName $STG.ResourceGroupName

$STGName = $STG.StorageAccountName
$ctx = $StorageAccount.Context

$CNTS = Get-AzureRmStorageContainer -ResourceGroupName $stg.ResourceGroupName -StorageAccountName $STG.StorageAccountName

Foreach ($CNT in $CNTS)

{
    $container = Get-AzureRmStorageContainer -ResourceGroupName $STG.ResourceGroupName -StorageAccountName $STG.StorageAccountName -Name $CNT.Name
    
    $containerName = $container.Name
    
    $listBlobs = Get-AzureStorageBlob -Container $containerName -Context $ctx

        
    Foreach ($listBlob in $listBlobs)

    {
        $blobsize = Get-AzureStorageBlob -Container $containerName -Context $ctx -Blob $listBlob.Name

        $blobName = $blobsize.Name
        $FileSize = $blobsize.Length

        Write-Output "Storage Account Name = $STGName"
        Write-Output "Storage Account Container Name = $containerName"
        Write-Output "Blob Name = $blobName"
        Write-Output "Blob Size = $FileSize"

        $details  = @{ 

        'SubscriptioName' = "$SubscriptionName"
        'StorageAccountName' = "$STGName"
        'ContainerName' = "$containerName"
        'BlobName' = "$blobName"
        'BlobSize' = "$FileSize"

        }

$results += New-Object PSObject -Property $details

    }

}

}
}
$results | Select "SubscriptioName","StorageAccountName","ContainerName","BlobName","BlobSize" | Export-Csv -Path $Output 
