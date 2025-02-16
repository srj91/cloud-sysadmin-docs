Param
    (
        [Parameter(Mandatory=$true)]
        [String] $vmname,

        [Parameter(Mandatory=$true)]
        [String] $resourcegroup

       
    )

try
{
$ErrorActionPreference="Stop"
$Credentials = Get-AutomationPSCredential -Name "runbookadmin"
$subscriptionId ='e52a8148-650f-41f2-baa4-9d49ff5e3317' #‘{your subscriptionId}’
$SubtenantId ='b27afcfc-40ae-465f-80fd-9263d5156c41' #‘{your tenantId}’
Login-AzureRmAccount -Credential $Credentials -SubscriptionId $subscriptionId -TenantId $SubtenantId   
"#******************************* Successfully Logged in to Azure Run As Connection ********************************#"

Start-AzureRmVM -Name $vmname -ResourceGroupName $resourcegroup

#Mail Veriables(This will execute on success)
$Toemailaddress="krishna.singh@beehivesoftware.in"
$From = "NoReply.G7CRAlert@g7cr.in"
$Subject = "VM Start : $((Get-Date).ToShortDateString())"
$body = "Hello,<br> </br>" 
$body += "$vmname has been started successfully.<br> </br>"
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


catch
{
$err = $_.Exception
write-output $err.Message
    
#Mail Veriables(This executes on failure)
$Toemailaddress="cloudsupport@g7cr.in; krishna.singh@beehivesoftware.in"
$From = "NoReply.G7CRAlert@g7cr.in"
$Subject = "VM Start Failed high Importance!!! : $((Get-Date).ToShortDateString())"
$body = "Hello,<br> </br>" 
$body += "Failed to start $vmname for Customer: Beehive Software Services Pvt Ltd,Sub ID: $subscriptionId. Please check.<br> </br>"
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

