Login-AzureRmAccount

#sub=Get-AzureRmSubscription

Select-AzureRmSubscription -SubscriptionName "AutomateStartStopSubscription-CSP"





$ErrorActionPreference = "silentlycontinue"




$StartDateAndTime = "2018-07-21T00:00:00.0Z"
$EndDateAndTime = "2018-08-22T00:00:00.0Z"

[string]$omsworkspaceid= "331ce9e5-9fa0-40d4-a5db-cbb135b54c83"

$path="C:\Users\Empower\Desktop\OMS-Log\"


#Heartbeat | where TimeGenerated > ago(1h)
#Heartbeat | summarize arg_max(TimeGenerated, *) by Computer


$queryResults=Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query 'Heartbeat | summarize arg_max(TimeGenerated, *) by Computer'

$vms=$queryResults.Results


Write-Host "We heard a heart beat for the following Machines.Note:The list of VM's will be exported to excel sheet" -ForegroundColor Yellow


$vms.Resource|Select-Object -Unique

Write-Host "Exporting....." -ForegroundColor Green

$vms.Resource |Select-Object -Unique| Export-Excel -Path "$path\Heartbeats.xlsx"


foreach($vm in $vms)
{

$ErrorActionPreference = "silentlycontinue"

#host name
$vmName=$vm.Computer


#vm Name
$vmResourceName=$vm.Resource
#ostype
$ostype=$vm.OSType


Write-Host "Running queries for the Machine Named $vmResourceName ,Host Name : $vmName, OStype : $ostype" -ForegroundColor Yellow




if ($vm.OsType -eq "Windows")

{

[string]$query="Perf | where CounterName == '% Processor Time' and InstanceName == '_Total' | summarize Avg_CPU = avg(CounterValue), Min_CPU= min(CounterValue), Max_CPU = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query2="Perf | where CounterName == '% Committed Bytes In Use' | summarize Avg_MemoryUsed = avg(CounterValue), Min_MemoryUsed = min(CounterValue), Max_MemoryUsed= max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query3="Perf | where CounterName == 'Available MBytes' | summarize Avg_MemoryAvailable = avg(CounterValue), Min_MemoryAvailable = min(CounterValue), Max_MemoryAvailable = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query4="Perf | where CounterName == 'Disk Reads/sec'| summarize Avg_DiskRead = avg(CounterValue), Min_DiskRead = min(CounterValue), Max_DiskRead = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query5="Perf | where CounterName == 'Disk Writes/sec' | summarize Avg_DiskWrite = avg(CounterValue), Min_DiskWrite = min(CounterValue), Max_DiskWrite = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"


$array1 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array2 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query2 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array3 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query3 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array4 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query4 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array5 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query5 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)




New-Item -Force -ItemType directory -Path "C:\Users\Empower\Desktop\OMS-Log\$vmname"





$array1.Results | Export-Excel -Path "$path\$vmname\Processor Time.xlsx"
$array2.Results | Export-Excel -Path "$path\$vmname\Committed Bytes In Use.xlsx"
$array3.Results | Export-Excel -Path "$path\$vmname\Available MBytes.xlsx"
$array4.Results | Export-Excel -Path "$path\$vmname\Disk Reads.xlsx"
$array5.Results | Export-Excel -Path "$path\$vmname\Disk Writes.xlsx"




}

Elseif ($vm.OsType -eq "Linux")

{


[string]$query="Perf | where CounterName == '% Processor Time' and InstanceName == '_Total' | summarize Avg_CPU = avg(CounterValue), Min_CPU= min(CounterValue), Max_CPU = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query2="Perf | where CounterName == '% Used Memory' | summarize Avg_MemoryInUse = avg(CounterValue), Min_MemoryInUse = min(CounterValue), Max_MemoryInUse  = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query3="Perf | where CounterName == 'Available MBytes Memory' | summarize Avg_MemoryAvailable = avg(CounterValue), Min_MemoryAvailable = min(CounterValue), Max_MemoryAvailable = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query4="Perf | where CounterName == 'Disk Reads/sec'| summarize Avg_DiskRead = avg(CounterValue), Min_DiskRead = min(CounterValue), Max_DiskRead = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"
[string]$query5="Perf | where CounterName == 'Disk Writes/sec'| summarize Avg_DiskWrite = avg(CounterValue), Min_DiskWrite = min(CounterValue), Max_DiskWrite = max(CounterValue) by Computer, bin(TimeGenerated, 15min)| where Computer == '$vmName'"



$array1 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array2 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query2 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array3 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query3 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array4 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query4 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)
$array5 = Invoke-AzureRmOperationalInsightsQuery -WorkspaceId $omsworkspaceid -Query $query5 -Timespan (New-TimeSpan -Start $StartDateAndTime -End $EndDateAndTime)




New-Item -Force -ItemType directory -Path "C:\Users\Empower\Desktop\OMS-Log\$vmname"


$array1.Results | Export-Excel -Path "$path\$vmname\ProcessorTime.xlsx"
$array2.Results | Export-Excel -Path "$path\$vmname\Used Memory.xlsx"
$array3.Results | Export-Excel -Path "$path\$vmname\Available MBytes Memory.xlsx"
$array4.Results | Export-Excel -Path "$path\$vmname\Disk Readssec.xlsx"
$array5.Results | Export-Excel -Path "$path\$vmname\Disk Writessec.xlsx"




}
}
