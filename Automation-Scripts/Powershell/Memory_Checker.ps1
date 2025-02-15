# Get Computer Object
 $CompObject =  Get-WmiObject -Class WIN32_OperatingSystem
 $Memory = ((($CompObject.TotalVisibleMemorySize - $CompObject.FreePhysicalMemory)*100)/ $CompObject.TotalVisibleMemorySize)
  
  
# Top 5 process Memory Usage (MB)
 $processMemoryUsage = Get-WmiObject WIN32_PROCESS | Sort-Object -Property ws -Descending | Select-Object -first 5 processname, @{Name="Mem Usage(MB)";Expression={[math]::round($_.ws / 1mb)}} | convertto-html -Fragment

#create an html email body 
 $body = @"
    <html>
        <body style="font-family:calibri"> 
        <b>Memory usage in percent:  $Memory</b>
        <br></br>
        <br>Following processes consume more: $processMemoryUsage</br>
        </body>
    </html>
"@     

 if ($Memory -gt 85)
 {
$userName = 'noreply-apprise@aptean.com'
$password = 'Winter@123'
[SecureString]$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force 

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securepassword
Send-MailMessage -BodyAsHtml -SmtpServer smtp.office365.com -Port 587 -UseSsl -From noreply-apprise@aptean.com -To suraj.chopade@aptean.com -Subject 'CRITICAL - MHW01 Memory Usage' -Body $body -Credential $credential

}