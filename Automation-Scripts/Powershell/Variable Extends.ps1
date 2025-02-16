#==============================================================================
# Created by:- Suraj Chopade
# Note:- Change the path accordingly
# Description:- 
# This script will validate the critical extends and will send email to 
# mentioned user accounts. 
#
#==============================================================================


#-------- define variables ---------#
$AppriseExtendscount = Get-Content -Path "C:\replication\monitoring\Apprise.txt" 
$CustomExtendscount = Get-Content -Path "C:\replication\monitoring\Custom.txt" 
$file = (Get-ChildItem C:\replication\monitoring\Apprise.txt).BaseName
$file1 = (Get-ChildItem C:\replication\monitoring\Custom.txt).BaseName

#--------- send email for action performed ---------#
if ($AppriseExtendscount.Contains("CRITICAL") )
    {
     $output = "Stevesilver01 has "+ $AppriseExtendscount +" for their Live $file database. "
     $userName = 'noreply-apprise@aptean.com'
     $password = 'Winter@123'
     [SecureString]$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force 
     $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securepassword
     Send-MailMessage -SmtpServer smtp.office365.com -Port 587 -UseSsl -From noreply-apprise@aptean.com -To ApteanSRE-Jedi@aptean.com -Subject 'CRITICAL - Extents are critical' -Body $output -Credential $credential
    }

if ($CustomExtendscount.Contains("CRITICAL"))
    {
     $output1 = "Stevesilver01 has "+ $CustomExtendscount +" for their Live $file1 database. "
     $userName = 'noreply-apprise@aptean.com'
     $password = 'Winter@123'
     [SecureString]$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force 
     $credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securepassword
     Send-MailMessage -SmtpServer smtp.office365.com -Port 587 -UseSsl -From noreply-apprise@aptean.com -To ApteanSRE-Jedi@aptean.com -Subject 'CRITICAL - Extents are critical' -Body $output1 -Credential $credential
    }
