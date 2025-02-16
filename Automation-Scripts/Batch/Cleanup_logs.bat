REM Setup the Date for the identification
for /F "tokens=2 delims==" %%D in ('wmic OS get LocalDateTime /VALUE') do set "TDATE=%%D"
set "TDATE=%TDATE:~,8%"
set ArchiveFolder="E:\Logs\SeriLogs\Archive_Files_Logs"

REM Create Folder for logs and files archive
mkdir %ArchiveFolder%-%TDATE%\NC_Logs
mkdir %ArchiveFolder%-%TDATE%\SSM_Logs
mkdir %ArchiveFolder%-%TDATE%\C-Temp
mkdir %ArchiveFolder%-%TDATE%\SchedulingAssistant\FastSA\Live
mkdir %ArchiveFolder%-%TDATE%\SchedulingAssistant\FastSA\Test
mkdir %ArchiveFolder%-%TDATE%\SchedulingAssistant\Live
mkdir %ArchiveFolder%-%TDATE%\SchedulingAssistant\Test
mkdir %ArchiveFolder%-%TDATE%\SchedulingAssistant\Conv
mkdir %ArchiveFolder%-%TDATE%\E-Temp-Live
mkdir %ArchiveFolder%-%TDATE%\E-Temp-Test
mkdir %ArchiveFolder%-%TDATE%\E-Temp-Conv

REM move files older than 2 days
forfiles /p E:\Logs\SeriLogs\NC /m *.* /s /d -2 /c "cmd /c move @file E:\Logs\SeriLogs\Archive_Files_Logs-%TDATE%\NC_Logs"
forfiles /p E:\Logs\SeriLogs\SSM /m *.* /d -2 /c "cmd /c move @file E:\Logs\SeriLogs\Archive_Files_Logs-%TDATE%\SSM_Logs"
forfiles /p C:\Temp\Logs /m *.* /d -2 /c "cmd /c move @file  E:\Logs\SeriLogs\Archive_Files_Logs-%TDATE%\C-Temp_NC_Log"

REM zip the newly moved files
cd E:
"C:\Program Files\7-Zip\7z.exe" a -sdel E:\Logs\SeriLogs\Archive_Files_Logs-%TDATE%.zip E:\Logs\SeriLogs\Archive_Files_Logs-%TDATE%\*

REM Delete the backed up files older than 7 days
forfiles -p E:\Logs\SeriLogs\Archive_Files_Logs /s /m *.* /d -2 /C "cmd /c del /q @PATH"

