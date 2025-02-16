$List_of_Disks=get-WmiObject win32_logicaldisk -Computername $env:COMPUTERNAME

$D_Data=$List_of_Disks | Select-Object DeviceID , Size , Freespace

Function Email{
$From = "Enter email address" #From address of the email

$To = "Enter email address" #To address of the email

$Cc = "Enter email address","Enter email address" #cc multiple ids

$Subject = "Disk Space" # Subject of Email

$Body =  "Disk space is getting full. Right Now it's more than 90% on virtual machine  - " +$env:COMPUTERNAME # MSG for Email

$SMTPServer = "enter smtp server" # Email Provider Details

$SMTPPort = "587" #port Number

<#Login Details of Email#>

$username = $From
$password = ConvertTo-SecureString 'Enter password for SMTP' -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential ($From, $password)
<#Email Code #>
Send-MailMessage -From $From -to $To -Cc $Cc  -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential ($credential)  –DeliveryNotificationOption OnSuccess

}

for($i=0; $i -lt $D_Data.Count; $i++){

$Csquare=$D_Data[$i]

$Current_Size=($Csquare.Size - $Csquare.Freespace)

$thresholdPercentage = 90


if($Csquare.Size -gt 0)
{
if($Current_Size -gt ($Csquare.size * ($thresholdPercentage / 100))){

write-host $Csquare
Email 



}
else

 {


write-host " Right Now i'm less than 90%"



 }

}
}