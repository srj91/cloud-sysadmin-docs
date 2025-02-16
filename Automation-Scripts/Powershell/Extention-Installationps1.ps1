#Login-AzureRmAccount


Select-AzureRmSubscription -Subscription "c2327cd8-9874-432f-9450-d308f1c583a9"


$ErrorActionPreference="SilentlyContinue"

#please change the path and execute

$csv=Import-csv -Path "C:\Users\Empower\Desktop\Final-NWAegisvm list.csv"



Foreach($myvm in $csv)
{
    try
    {


    $myvmname=$myvm.Name
    $myRGname=$myvm.ResourceGroupName
    Write-Host "Script execution in progress for vm name $myvmname" -ForegroundColor Green


    $vm= Get-AzureRmVM | ?  {$_.Name -eq $myvmname -and $_.ResourceGroupName -eq $myRGname} |Select ResourceGroupName,Name,Location,Id
    $rgName=$null
    $rgName=$vm.ResourceGroupName
    $vmName=$null
    $vmName=$vm.Name
    $Location=$vm.Location
         $getextension=$null
         $extensionname=$null
         $extensionname2=$null
        $getextension=get-AzureRmVMExtension -ResourceGroupName $rgName -VMName $vmName -Name "AzureNetworkWatcherExtension"
        $getextension2=get-AzureRmVMExtension -ResourceGroupName $rgName -VMName $vmName -Name "networkWatcherAgent" 


        $extensionname=$getextension.Name
        $extensionname2=$getextension2.Name
        if($extensionname  -eq $null -and $extensionname2 -eq $null)
        {
            Write-Host "No extension found for  vm name $vmName... Adding extension fist..Please Wait" -ForegroundColor Yellow
            #Install Network Watcher Agent
            Set-AzureRmVMExtension `
              -ResourceGroupName $rgName `
              -Location $Location `
              -VMName $vmName `
              -Name "AzureNetworkWatcherExtension" `
              -Publisher "Microsoft.Azure.NetworkWatcher" `
              -Type "NetworkWatcherAgentWindows" `
              -TypeHandlerVersion "1.4"


              Write-Host "Added extension for $vmName" -ForegroundColor Green
            }
    
        }
         catch
        {
                    $err = $_.Exception
                    write-host $err.Message
        }



}
