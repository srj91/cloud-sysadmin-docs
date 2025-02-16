Param
    (
        [Parameter(Mandatory=$true)]
        [String] $vmname,

        [Parameter(Mandatory=$true)]
        [String] $resourcegroup,

        [Parameter(Mandatory=$true)]
        [String] $vmsize
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

$day = (Get-Date).DayOfWeek
    if ($day -eq 'Sunday'){
       Write-Output "Exiting from Script as it is Sunday"
        exit
}

$vm = Get-AzureRmVM -ResourceGroupName $resourcegroup -VMName $vmname 
$size = $vm.HardwareProfile.VmSize

Write-Output "Current VM $size"

if($vm.HardwareProfile.VmSize -ne $vmsize)
{
  # VM resize
  Write-Output "Resizing $vmname"
  $vm.HardwareProfile.VmSize = "$vmsize"
  Stop-AzureRmVM -Name $vmname -ResourceGroupName $resourcegroup -Force
  Update-AzureRmVM -VM $vm -ResourceGroupName $resourcegroup
  Start-AzureRmVM -Name $vmname -ResourceGroupName $resourcegroup
  Write-Output "$vmname Resized"
}

Else

{Write-Output "VM is already in $size"} 
