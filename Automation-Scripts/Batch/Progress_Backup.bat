REM Set TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

REM Set date value as (i.e "20210609")
for /F "tokens=2 delims==" %%D in ('wmic OS get LocalDateTime /VALUE') do set "TDATE=%%D"
set "TDATE=%TDATE:~,8%"

REM Run probkup from creating .BK backup files
echo Creating backups... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
E:
cd E:\Progress\OpenEdge12.2\bin
call probkup online E:\AppriseDB\8.3.1\Live\apprise E:\AppriseDB\Backups\live-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
call probkup online E:\AppriseDB\8.3.1\Live\custom E:\AppriseDB\Backups\livecustom-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
call probkup online E:\AppriseDB\AppCenter\appcenter\appcenter E:\AppriseDB\Backups\appcenter-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
call probkup online E:\AppriseDB\AppCenter\framework\framework E:\AppriseDB\Backups\framework-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt

REM Verify backup
echo Verifying backups... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
call prorest E:\AppriseDB\8.2.0\Live\apprise E:\AppriseDB\Backups\live-%tDate%.BK -vp >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
call prorest E:\AppriseDB\8.2.0\Live\custom E:\AppriseDB\Backups\live-%tDate%.BK -vp >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt

REM Archive backups and create ZIP file for backup
echo Archiving backups... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
E:
cd E:\AppriseDB\Backups
echo Zipping Live Apprise Backup... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
"C:\Program Files\7-Zip\7z.exe" a -sdel E:\AppriseDB\Backups\Live-%tDate%.zip E:\AppriseDB\Backups\live-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
echo Zipping Live Custom Backup... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
"C:\Program Files\7-Zip\7z.exe" a -sdel E:\AppriseDB\Backups\Live-%tDate%.zip E:\AppriseDB\Backups\livecustom-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
echo Zipping Appcenter Backup... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
"C:\Program Files\7-Zip\7z.exe" a -sdel E:\AppriseDB\Backups\Live-%tDate%.zip E:\AppriseDB\Backups\appcenter-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
echo Zipping Live Framework Backup... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
"C:\Program Files\7-Zip\7z.exe" a -sdel E:\AppriseDB\Backups\Live-%tDate%.zip E:\AppriseDB\Backups\framework-%tDate%.BK >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt

REM sync backup folder to Blob storage account "strgeastusprdappr"
echo Syncing backups to Blob storage... >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt
"C:\Program Files (x86)\Microsoft SDKs\Azure\AzCopy\AzCopy.exe" /Source:E:\AppriseDB\Backups\ /Dest:https://strgeastusprdappr.blob.core.windows.net/distribution01/ /DestKey:uUAdpLf78tgrzLS3bseQBUGduUS2UihwuGQCMvjTHdy6RQ1Ph0ke8iSKeP7wXlFlOzfxajZiFc/WF+G5UF9QZQ== /S /XO /Y >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt

REM Write completion message to log
echo Backup process completed successfully. >> E:\AppriseDB\Backups\backup_log-%TDATE%.txt

REM Trigger alert
powershell -ExecutionPolicy Bypass -Command "& {Send-MailMessage -SmtpServer 'smtp.office365.com' -Port 587 -UseSsl -From 'noreply-apprise@aptean.com' -To 'ApteanSRE-Jedi@aptean.com' -Subject 'Distribution01 - Backup process completed' -Body 'Please Check the attachment and if anything critical, please reach out to Tech-Hub.' -Credential (New-Object System.Management.Automation.PSCredential -ArgumentList 'noreply-apprise@aptean.com', (ConvertTo-SecureString -String 'Winter@123' -AsPlainText -Force)) -Attachment 'E:\AppriseDB\Backups\backup_log-%TDATE%.txt'}"

REM Delete Backup older than 1 days
forfiles -p . /s /m *.* /d -1 /C "cmd /c del /q @PATH"
