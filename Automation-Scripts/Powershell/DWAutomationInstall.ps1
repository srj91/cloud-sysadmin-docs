#---- prerequisites installation ----#
Install-Module PostgreSQLCmdlets -Scope AllUsers -force -SkipPublisherCheck

#----- Define Variables -----#

$URL = 'https://ftp.postgresql.org/pub/pgadmin/pgadmin4/v6.14/windows/pgadmin4-6.14-x64.exe'
$path = 'c:\temp\pgadmin4-6.14-x64.exe'
$pgadmin_exe_path = 'C:\Program Files\pgAdmin 4\v6\runtime\pgAdmin4.exe'
$DisableMRootPwd = 'C:\Program Files\pgAdmin 4\v6\web\config.py'


#---- download and Install PGadmin also disable master password ----#

Invoke-WebRequest -Uri $URL -OutFile $path
$command = “cmd.exe /c $path /VERYSILENT /LOG /NORESTART /ALLUSERS"
$process = [WMICLASS]“\\82image\ROOT\CIMV2:win32_process“
$process.Create($command)

(Get-Content -Path $DisableMRootPwd) -replace 'MASTER_PASSWORD_REQUIRED = True','MASTER_PASSWORD_REQUIRED = False' > C:\Temp\config.py  
Copy-Item 'C:\Temp\config.py' -Destination 'C:\Program Files\pgAdmin 4\v6\web\config.py'
Start-Process -FilePath $pgadmin_exe_path