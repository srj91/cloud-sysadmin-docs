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
 
$RGName = "Snapshots-RG"
 
$Snapshots = Get-AzureRmSnapshot -ResourceGroupName $RGName
 
$Date = (Get-Date).AddDays(-3)
 
Foreach ($Snapshot in $Snapshots)
 
{
    If ($Snapshot.TimeCreated -lt $Date)
 
        {
            $Snapshot.Name
            $Snapshot.TimeCreated
 
            Remove-AzureRmSnapshot -ResourceGroupName $Snapshot.ResourceGroupName -SnapshotName $Snapshot.Name -Force
      
        }
 
}