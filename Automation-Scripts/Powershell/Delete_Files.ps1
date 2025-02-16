#==============================================================================
# Created by:- Suraj Chopade
# Note:- Change the path accordingly
# Description:- 
# This script will delete the files in specified path and will send email to 
# mentioned user accounts. 
#
#==============================================================================


#-------- define variables ---------#
$Path = "C:\users\schopade\Downloads"
$Daysback = "-10"
$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)

#-------- find the files recursively ---------#
Get-ChildItem $Path -Recurse | Where-Object { $_.LastWriteTime -lt $DatetoDelete }  | Out-File "C:\My-Data\deletedFiles.txt" | Remove-Item  
#--------- send email for action performed ---------#

Function Email
{
$From = "no-reply@aptean.com" #From address of the email
$To = "pawan.vernekar@aptean.com" #To address of the email
$Cc = "suraj.chopade@aptean.com"
$Subject = "Files deleted" # Subject of Email
$Body = "The list of the deleted files is in path Out-File C:\My-Data\deletedFiles.txt of VM" +$env:COMPUTERNAME  # MSG for Email
$SMTPServer = "smtp.office365.com" # Email Provider Details
$SMTPPort = "587" #port Number

#--------- Login Details of Email ----------#
$username = $From
$password = ConvertTo-SecureString 'HA@65tdEaA01' -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($From, $password)

#--------- Email Code -------- #
Send-MailMessage -From $From -to $To -Cc $Cc  -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential ($credential) –DeliveryNotificationOption OnSuccess
}



