param (
            [parameter(Mandatory=$true)]
            [String]$resourceGroupName,
            
            [Parameter(Mandatory = $true)] 
            [String]$StorageAccountName,

<#
            [Parameter(Mandatory = $true)] 
            [String]$ContainerName,

#>
            [Parameter(Mandatory = $true)]
            [Int32]$DaysOld
        )


 "#******************************* Login to Azure Run As Connection ********************************************#"
$connectionName = "AzureRunAsConnection"
    
Try
    {
# Get the connection "AzureRunAsConnection"
        
            $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         





"Logging in to Azure..."





            Add-AzureRmAccount -ServicePrincipal -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }





Catch 
    {
        if (!$servicePrincipalConnection)
            {
                $ErrorMessage = "Connection $connectionName not found."
                throw $ErrorMessage
            } 
        else
            {
                Write-Error -Message $_.Exception
                throw $_.Exception
                $ErrorMessage = $_.Exception





            }
    }   
"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"


$blobnameext = "bacpac"


$storageaccount = Get-AzureRmStorageAccount -ResourceGroupName $resourceGroupName -Name $StorageAccountName
#$STGkey = Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroupName -Name $StorageAccountName 
#$key = $STGKey.Value[0]
$context = $storageaccount.Context


$STGCNT = Get-AzureRmStorageContainer -ResourceGroupName $resourceGroupName -StorageAccountName $StorageAccountName   #-Name $ContainerName
$STGCNT 
Foreach ($cont in $STGCNT )
{

    $CNTname =$cont.Name
 
   

    $blobs = Get-AzureStorageBlob -Container $CNTname -Context $context

    $blobs


    $blobs = $blobs | Where-Object {$_.Name -like '*.'+$blobnameext}

    
    Foreach  ($blob in $blobs)
    {
        $blobname = $blob.Name    
        $lastmodfied = $blob.LastModified


        $blobdays = ([DateTime]::Now - $lastmodfied.DateTime)
        
        If ($blobdays.Days -gt $DaysOld)
        
            {
                Write-Output "Deleting Azure Storage Blob = $blobname"
                Remove-AzureStorageBlob -Blob $blobname -Container $CNTname -Context $context -Force
            
            }    


        Else
            {
                Write-Output "Not Removing Azure Storage blob - $blobname - as it is not old enough"
            }
    }
    

}


















