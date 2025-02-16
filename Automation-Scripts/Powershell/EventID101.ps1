# Define email parameters
$recipientEmail = "suraj.chopade@aptean.com"
$senderEmail = "noreply@example.com"
$smtpServer = "smtp.office365.com"
$smtpPort = 587
$smtpUsername = "noreply@example.com"
$smtpPassword = "password"

# Get the current date and time 15 minutes ago
$startTime = (Get-Date).AddMinutes(-15)

# Define the event log name and ID
$logName = "Application && Data Logs"
$eventId = 101

# Filter the event log for Event ID 101 in the last 15 minutes
$events = Get-WinEvent -LogName $logName -FilterHashtable @{ID=$eventId; StartTime=$startTime}

# If any events are found, collect the details and trigger an email alert
if ($events) {
    foreach ($event in $events) {
        $taskName = $event.Properties[5].Value
        $taskResult = $event.Properties[8].Value

        # Check if the task name matches "SFTP task"
        if ($taskName -eq 'ECOM' -or $taskName -eq 'SFTP - Aptean EDI Push & Pull Files') {
            # Define email parameters
            $subject = "Alert: Scheduled Task Failed on $env:COMPUTERNAME"
            # Construct the email body with user-friendly formatting
            $body = @"
            Dear Team,

            The scheduled task named '$taskName' failed on server $env:COMPUTERNAME.

            Task Result: $taskResult

            Please investigate and take appropriate actions to resolve the issue.

            Thank you,
            Apprise TechHUB
"@
            # Send email alert
            Send-MailMessage -To $recipientEmail -From $senderEmail -Subject $subject -Body $body -SmtpServer $smtpServer -Port $smtpPort -Credential (New-Object System.Management.Automation.PSCredential ($smtpUsername, (ConvertTo-SecureString $smtpPassword -AsPlainText -Force))) -UseSsl
        }
    }
}
