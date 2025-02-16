try
{
$usererror=@()
#Connect-MsolService
$csv=Import-Csv -Path "C:\Users\shankar\Desktop\aegs.csv"
Foreach($user in $csv)
{
New-MsolUser -UserPrincipalName $user.UserPrincipalName -DisplayName $user.DisplayName -UsageLocation $user.UsageLocation -Password $user.Password -ForceChangePassword $True
$username=Get-MsolUser -UserPrincipalName $user.UserPrincipalName
Write-Host $username.UserPrincipalName -ForegroundColor Green
if($username -eq $null)
{
$info=""|Select UserPrincipalName,DisplayName,UsageLocation,LicenseAssignment,Password
$info.UserPrincipalName=$user.UserPrincipalName
$info.DisplayName=$user.DisplayName
$info.UsageLocation=$user.UsageLocation
$info.Password=$user.Password
$usererror+=$info
}
}
$usererror|Export-csv -Path "C:\Users\shankar\Desktop\aegserror.csv"
}
catch
{
$Error[0]
}
