# Ensure you have the Azure PowerShell module installed
# Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Connect to Azure
Connect-AzAccount -SubscriptionId 'b70a2671-32f1-40f6-a1f7-0639a811a4a5'

# Get all Storage Accounts in the subscription
$storageAccounts = Get-AzStorageAccount

# Initialize an array to hold Storage Accounts with TLS 1.0
$tls1StorageAccounts = @()

# Check each Storage Account's Minimum TLS version
foreach ($storageAccount in $storageAccounts) {
    $account = Get-AzStorageAccount -ResourceGroupName $storageAccount.ResourceGroupName -Name $storageAccount.StorageAccountName
    if ($account.MinimumTlsVersion -eq "TLS1_0") {
        $tls1StorageAccounts += $account.StorageAccountName
    }
}

# Output the Storage Accounts with TLS 1.0
if ($tls1StorageAccounts.Count -eq 0) {
    Write-Output "No Storage Accounts with TLS 1.0 found."
} else {
    Write-Output "Storage Accounts with TLS 1.0:"
    $tls1StorageAccounts | ForEach-Object { Write-Output $_ }
}
