Connect-AzureRmAccount -Subscription "Manowar-G7CR"

$VMachines=Get-AzureRmVM -ResourceGroupName "Suraj-RG"

    ForEach ($VMachine in $VMachines)
    {

      write-host Total Machines are $VMachines.count and current machine is $vmachine.Name
      
      Invoke-AzureRmVMRunCommand -ResourceGroupName $VMachine.ResourceGroupName -Name $VMachine.Name -CommandId 'RunShellScript' -ScriptPath 'C:\Users\G7CR\Desktop\apacheconfig.sh'
      
      Write-Host SSH Service status updated for $VMachine.Name Machine
    
    }

   