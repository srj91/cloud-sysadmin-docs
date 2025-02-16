#Login-AzureRmAccount

$results = @()

$Resources

$AutoShutdown = "C:\Users\G7CR\Desktop\AutoShutdown.csv"


$subs = Get-AzureRmSubscription

Foreach ($Sub in $subs)

{

Select-AzureRmSubscription -SubscriptionName $Sub.Name

$Resources = Get-AzureRmResource

foreach ($Resource in $Resources)

    {

        if ($Resource.ResourceType -match "Microsoft.DevTestLab")

        {

            $details  = @{ 
                            'SubscriptionName' = $Sub.Name
                            'ResourceGroupName' = $Resource.ResourceGroupName
                            'ResourceName' = $Resource.Name.Split('-')[2]
                            'ResourceType' = $Resource.Id
                        }

            $results += New-Object PSObject -Property $details
        
        }

    }

}

$results | Select "SubscriptionName","ResourceGroupName","ResourceName","ResourceType" | Export-Csv -Path $AutoShutdown



