Param 
    (

        [Parameter(Mandatory=$true)]
        [String] $TenantID,

        [Parameter(Mandatory=$true)]
        [String] $AppID,

        [Parameter(Mandatory=$true)]
        [String] $AppSecretKey,

        [Parameter(Mandatory=$true)]
        [String] $STGRGName,

        [Parameter(Mandatory=$true)]
        [String] $STGName,

        [Parameter(Mandatory=$true)]
        [String] $STGContainer

    )


$ErrorActionPreference = "SilentlyContinue"

$ScriptLocation = $env:TEMP + "\"
#$LinuxDiskSize = "LinuxDiskSize.sh"
$WindowsHostName = "script.ps1"


$cred = New-Object PSCredential $AppID, ($AppSecretKey | ConvertTo-SecureString -AsPlainText -Force)

Connect-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $TenantID 


        $stg = Get-AzureRmStorageAccount -ResourceGroupName $STGRGName -Name $STGName
        
        $srcContext = $stg.Context

#        Get-AzureStorageBlobContent -Blob $LinuxDiskSize -Container $STGContainer -Destination $ScriptLocation -Context $srcContext -Force
        
        Get-AzureStorageBlobContent -Blob $WindowsHostName -Container $STGContainer -Destination $ScriptLocation -Context $srcContext -Force

  
$LinuxSrciptPath = $ScriptLocation + $LinuxDiskSize
$WindowsScriptPath = $ScriptLocation + $WindowsHostName

$LinuxSrciptPath
$WindowsScriptPath

$ErrorActionPreference = "SilentlyContinue"

$VMS = Get-AzureRMVM

Foreach ($VM in $VMS)

{

    $VMName = $VM.Name
    $RGName = $VM.ResourceGroupName

    $VMDetails = Get-AzureRmVM -ResourceGroupName $RGName -Name $VMName -Status

    $VMStatus = $VMDetails.Statuses.DisplayStatus

    If ($VMStatus -eq "VM running")

        {

            if ($VM.StorageProfile.OsDisk.OsType -eq "Linux")

                {
                    Write-Output "Linux OS VM ' $VMName ' is Running"
            
                    $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName `
                    -CommandId 'RunShellScript' -ScriptPath $LinuxSrciptPath

                    $diskuti.Value
                }


            Else
                {
                    Write-Output "Windows OS VM ' $VMName ' is Running"

                    $diskuti = Invoke-AzureRmVMRunCommand -VMName $VMName -ResourceGroupName $RGName `
                    -CommandId 'RunPowerShellScript' -ScriptPath $WindowsScriptPath

                    $diskuti.Value
                }

    }    
        
}

