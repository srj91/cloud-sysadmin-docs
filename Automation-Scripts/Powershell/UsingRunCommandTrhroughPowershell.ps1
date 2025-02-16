Connect-AzureRmAccount -Subscription  "Subscription_Name"

$VMachines=Get-AzureRmVM -ResourceGroupName "Resource_Group_Name"

    ForEach ($VMachine in $VMachines)
    {

      write-host Total Machines are $VMachines.count and current machine is $vmachine.Name

            Invoke-AzureRmVMRunCommand -ResourceGroupName $VMachine.ResourceGroupName -Name $VMachine.Name -CommandId 'RunShellScript' -ScriptPath 'C:\Users\G7CR\Desktop\test.sh'
      Write-Host SSH Service status updated for $VMachine.Name Machine
    
    }
