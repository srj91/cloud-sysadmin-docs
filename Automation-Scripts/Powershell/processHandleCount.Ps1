[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Configuration Variables
$processName = "SchedulingAssistantService"  # Replace with the actual process name
$threshold = 9500
$smtpServer = "smtp.office365.com"  # Replace with your SMTP server
$smtpPort = 587  # Common SMTP port for TLS; change if your server uses a different port
$smtpFrom = "noreply-apprise@aptean.com"  # Replace with the sender's email
$smtpTo = "suraj.chopade@aptean.com"  # Replace with the recipient's email
$emailSubject = "CRITICAL - Handle Count Alert"
$smtpCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList "noreply-apprise@aptean.com", (ConvertTo-SecureString "Winter@123" -AsPlainText -Force)

# Get the handle counts for all instances of the process
$processes = Get-Process -Name $processName -ErrorAction SilentlyContinue

# Check if there are any running instances of the process
if ($processes) {
    # Calculate the total handle count
    $totalHandleCount = ($processes | Measure-Object HandleCount -Sum).Sum

    # Create the HTML body content for the email
    $processHandleUsage = $processes | Sort-Object -Property HandleCount -Descending | Select-Object -First 5 -Property ProcessName, Id, @{Name="Count";Expression={[math]::round($_.HandleCount)}}
    
    $handleUsageHtml = $processHandleUsage | ConvertTo-Html -Fragment | Out-String
    
    $body = @"
    <html>
        <body style="font-family:calibri">
            <p><b>Combined Handle Count: $totalHandleCount</b></p>
            <p>The total combined handle count for process <b>$processName</b> has exceeded the threshold of $threshold handles. Please find the detailed process information below:</p>
            $handleUsageHtml
        </body>
    </html>
"@

    # Check if the total handle count exceeds the threshold
    if ($totalHandleCount -ge $threshold) {
        # Send email alert with HTML body
        Send-MailMessage -SmtpServer $smtpServer `
                         -Port $smtpPort `
                         -UseSsl `
                         -Credential $smtpCredential `
                         -From $smtpFrom `
                         -To $smtpTo `
                         -Subject $emailSubject `
                         -BodyAsHtml `
                         -Body $body

        # Log the alert
        Write-Output "Alert sent: Combined handle count exceeded $threshold. Current handle count: $totalHandleCount."
    }
} else {
    Write-Output "No instances of $processName are currently running."
}


