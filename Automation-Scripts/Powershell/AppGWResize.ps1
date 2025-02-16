Param
(
        [Parameter(Mandatory=$true)]
        [String] $ApplicationGatewayName,

        [Parameter(Mandatory=$true)]
        [String] $ResourceGroupName,

        [Parameter(Mandatory=$true)]
        [String]  $Name,
        
        [Parameter(Mandatory=$true)]
        [String]  $NewTier,

        [Parameter(Mandatory=$true)]
        [UInt32]  $IntanceCapacity
)
 
 "#******************************* Login to Azure Run As Connection ********************************************#"
 
$connectionName = "AzureRunAsConnection"
 
Try
{
        $ErrorActionPreference="Stop"
        Write-Output "Trying to Login"

        $Credentials = Get-AutomationPSCredential -Name "runbookadmin"
        $subscriptionId ='e52a8148-650f-41f2-baa4-9d49ff5e3317' #‘{your subscriptionId}’
        $SubtenantId ='b27afcfc-40ae-465f-80fd-9263d5156c41' #‘{your tenantId}’
        Login-AzureRmAccount -Credential $Credentials -SubscriptionId $subscriptionId -TenantId $SubtenantId 


        Write-Output "Logged IN successfully"

"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"

        $AppGwExisting = Get-AzureRmApplicationGateway -Name $ApplicationGatewayName -ResourceGroupName $ResourceGroupName


        Write-Output "Existing SKU :" $AppGwExisting.Sku

        

        if($AppGwExisting.sku.Capacity -eq $IntanceCapacity)
        {
                Write-Output "Enterd Applicationgateway $ApplicationGatewayName Instance capacity is Same as Existing Instance capacity."
        }

        Else
        {

        $AppGwUpdatedSku = Set-AzureRmApplicationGatewaySku -ApplicationGateway $AppGwExisting -Name $Name -Tier $NewTier -Capacity $IntanceCapacity

        $UpdatedAppGw = Set-AzureRmApplicationGateway -ApplicationGateway $AppGwExisting

        Write-Output "Updated SKU :" $UpdatedAppGw.Sku

    
        }
}

catch
{
        $err = $_.Exception
        write-output $err.Message
    
        #Mail Veriables(This executes on failure)
        $Toemailaddress="krishna.singh@beehivesoftware.in","cloudsupport@g7cr.in","akarsh.itigi@g7cr.in","praleeth.kp@g7cr.in"
        $From = "NoReply.G7CRAlert@g7cr.in"
        $Subject = "ApplicationGateway Instance Resize Failed high Importance!!! : $((Get-Date).ToShortDateString())"
        $body = "Hello,<br> </br>" 
        $body += "ApplicationGateway $ApplicationGatewayName Resize to $IntanceCapacity Instance Failed for Customer: Beehive Software Services Pvt Ltd,Sub ID: $subscriptionId. Please check.<br> </br>"
        $body += "<br> </br>Regs <br> </br> G7Support <br> </br>"
        $SMTPServer = "outlook.office365.com"
        $SMTPPort = "587"

        #Credential for From Mail ID
        $myCredential = Get-AutomationPSCredential -Name 'noreplay'
        $adminUsername = $myCredential.UserName
        $adminPassword = $myCredential.Password
        $cred = New-Object PSCredential ($adminUsername,$adminPassword)

        Write-Output "Mail sent"
        Send-MailMessage -From $From -to $Toemailaddress -Subject $Subject  -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml
}



