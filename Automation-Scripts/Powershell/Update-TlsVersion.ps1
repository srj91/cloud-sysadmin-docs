<#
.SYNOPSIS
    Updates the TLS version of Azure Storage Accounts to 1.2.
.DESCRIPTION
    This script reads a list of Azure Storage Account names from a text file and updates their TLS version to 1.2.
.PARAMETER StorageAccountListFilePath
    Path to the text file containing the list of Azure Storage Account names.
.EXAMPLE
    .\Update-TlsVersion.ps1 -StorageAccountListFilePath "storageaccounts.txt"
#>

param (
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountListFilePath
)

# Import the list of storage accounts
$storageAccounts = Get-Content -Path $StorageAccountListFilePath

foreach ($storageAccountName in $storageAccounts) {
    Write-Host "Updating TLS version for storage account: $storageAccountName"
    
    # Get the storage account
    $storageAccount = Get-AzStorageAccount -Name $storageAccountName -ErrorAction SilentlyContinue
    
    if ($null -ne $storageAccount) {
        try {
            # Update the minimum TLS version to 1.2
            $storageAccount.MinimumTlsVersion = "TLS1_2"
            Set-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName -MinimumTlsVersion $storageAccount.MinimumTlsVersion
            
            Write-Host "Successfully updated TLS version for storage account: $storageAccountName to TLS 1.2"
        } catch {
            Write-Host "Failed to update TLS version for storage account: $storageAccountName. Error: $_"
        }
    } else {
        Write-Host "Storage account: $storageAccountName not found."
    }
}
