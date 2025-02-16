Please find the script below to delete sql backup in storage account older than 7 days.

Parameters to be passed:
1) Storage Account Name
2) Storage Account Resource Group Name
3) Container Name
4) older than a number of days to be deleted

<#
.DESCRIPTION
    Removes all blobs with the extension mentioned older than a number of days back
#>

#Login-AzureRmAccount

param(
    [parameter(Mandatory=$true)]
    [String]$resourceGroupName,

    # StorageAccount name for content deletion.
    [Parameter(Mandatory = $true)] 
    [String]$StorageAccountName,

    # StorageContainer name for content deletion.
    [Parameter(Mandatory = $true)] 
    [String]$ContainerName,

    [Parameter(Mandatory = $true)]
    [Int32]$DaysOld

)
$backuptype="bak"

$keys = Get-AzureRMStorageAccountKey -ResourceGroupName $resourceGroupName -AccountName $StorageAccountName
# get the storage account key
Write-Host "The storage key is: "$StorageAccountKey;
# get the context
$StorageAccountContext = New-AzureStorageContext -storageAccountName $StorageAccountName -StorageAccountKey $keys.Value[0];
$StorageAccountContext;
$existingContainer = Get-AzureStorageContainer -Context $StorageAccountContext -Name $ContainerName;
#$existingContainer;
if (!$existingContainer)
{
"Could not find storage container";
} 
else 
{
$containerName = $existingContainer.Name;
Write-output ("Found {0} storage container" -f $containerName);
$blobs = Get-AzureStorageBlob -Container $containerName -Context $StorageAccountContext;

$blobs = $blobs  | Where-Object {$_.Name -like '*.'+$backuptype}
$blobsremoved = 0;


if ($blobs -ne $null)
{    
    foreach ($blob in $blobs)
    {
        $lastModified = $blob.LastModified
        if ($lastModified -ne $null)
        {
            #Write-Verbose ("Now is: {0} and LastModified is:{1}" –f [DateTime]::Now, [DateTime]$lastModified);
            #Write-Verbose ("lastModified: {0}" –f $lastModified);
            #Write-Verbose ("Now: {0}" –f [DateTime]::Now);
            $blobDays = ([DateTime]::Now - $lastModified.DateTime)  #[DateTime]

            Write-output ("Blob {0} has been in storage for {1} days" –f $blob.Name, $blobDays);

            Write-output ("blobDays.Days: {0}" –f $blobDays.Hours);
            Write-output ("DaysOld: {0}" –f $DaysOld);

            if ($blobDays.Days -ge $DaysOld)
            {
                Write-output ("Removing Blob: {0}" –f $blob.Name);

                Remove-AzureStorageBlob -Blob $blob.Name -Container $containerName -Context $StorageAccountContext;
                $blobsremoved += 1;
            }
            else {
                Write-output ("Not removing blob as it is not old enough.");
            }
        }
    }
}

Write-output ("{0} blobs removed from container {1}." –f $blobsremoved, $containerName);
}
