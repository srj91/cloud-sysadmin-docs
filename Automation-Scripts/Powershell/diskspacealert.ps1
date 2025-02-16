$List_of_Disks=get-WmiObject win32_logicaldisk -Computername $env:COMPUTERNAME


$D_Data=$List_of_Disks | Select-Object DeviceID , Size , Freespace

Function Email{
$From = "alert@beehivehcm.com" #From address of the email

$To = "suraj.chopade@g7cr.in" #To address of the email

$cc = "emil.m@g7cr.in","srj281191@gmail.com"   

$Subject = "Disk Space" # Subject of Email

$Body = "Disk space is getting full. Right Now it's more than 90% on virtual machine  - BeehiveHCM " # MSG for Email

$SMTPServer = "smtp.pepipost.com" # Email Provider Details

$SMTPPort = "587" #port Number

<#Login Details of Email#>

$username = $From
$password = ConvertTo-SecureString 'aadf52f1ec5bd6ae6af1af787d65e833' -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential ($From, $password)
<#Email Code #>
Send-MailMessage -From $From -to $To  -cc $cc -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential ($credential)  –DeliveryNotificationOption OnSuccess


}


for($i=0; $i -lt $D_Data.Count; $i++){

$Csquare=$D_Data[$i]

$Current_Size=($Csquare.Size - $Csquare.Freespace)

$thresholdPercentage = 20


if($Csquare.Size -gt 0)
{
if($Current_Size -gt ($Csquare.size * ($thresholdPercentage / 100))){

write-host $Csquare
Email 



}


else

 {


write-host " Right Now i'm less than 50%"



 }

}

}


09769143426 --------- krishna Beehive






