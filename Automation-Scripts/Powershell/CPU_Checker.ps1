#Resizable array you can add items to
[System.Collections.ArrayList]$List = @()

#Counter which is increased by 1 after getting each counter
$Counter = 0



#As long as the counter is less than the below value... (600 = 15 minutes)
While ($Counter -lt 300)
{
    #Get 1 counter per second
    $CpuTime = $(Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1).CounterSamples.CookedValue

    $table = Get-Counter -ErrorAction SilentlyContinue '\Process(*)\% Processor Time' | Select-Object -ExpandProperty countersamples| Select-Object -Property instancename, user, cookedvalue| ? {$_.instanceName -notmatch "^(idle|_total|system)$"} | Sort-Object -Property cookedvalue -Descending| Select-Object -First 5| select-object InstanceName,@{L='CPU';E={($_.Cookedvalue/100/$env:NUMBER_OF_PROCESSORS).toString('P')}} | convertto-html -Fragment

    #Add the CPU total time to the list
    $List.Add($CpuTime)

    #Increase the counter by 1. As we are getting one sample per second, this will be increased by one each second
    $Counter++
}

#create an html email body 
 $body = @"
    <html>
        <body style="font-family:cambria"> 
        <b>CPU usage in percent:  $CpuTime</b>
        <br></br>
        <br>Following processes consuming more CPU: $table</br>
        </body>
    </html>
"@   

#Get the minimum, average and maximum of the values stored in the list
$Measurements = $List | Measure-Object -Minimum -Average -Maximum

#Email bit. To be finished by you
If ($Measurements.Average -gt 90)
{
#$output = "Critical: MHW01 CPU is 90%..... Please look into it "
$userName = 'noreply-apprise@aptean.com'
$password = 'Winter@123'
[SecureString]$securepassword = $password | ConvertTo-SecureString -AsPlainText -Force 

$credential = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securepassword
Send-MailMessage -BodyAsHtml -SmtpServer smtp.office365.com -Port 587 -UseSsl -From noreply-apprise@aptean.com -To ApteanSRE-Jedi@aptean.com  -Subject 'CRITICAL - MHW01 Running with High CPU' -Body $body -Credential $credential

}