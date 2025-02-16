Import-Module activedirectory

$Users = Import-Csv -LiteralPath "C:\Users\UdaanCorpAdmin\Desktop\Udaan-UserList.csv"

foreach ($User in $Users)

{
    $Username = $User.UserID
    $Password = $User.Password
    $FirtName = $User.FirstName
    $LastName = $User.LastName
    $DisplayName = $User.DisplayName
    $EmailID = $User.EmailId
    $Department = $User.Department
    $Company = $User.Company
    $OU = "OU=Onrole,DC=corp,DC=udaan,DC=com"
    $City = $User.City
    $EmployeeId = $User.EmployeeId
    $Description = $user.Description
    $ManagerEmailId = $user.ManagerEmailId
    $Phone = $User.Phone

 
$DisplayName  

$NewADUser = New-ADUser -UserPrincipalName $EmailID `
            -DisplayName $DisplayName `
            -Name $DisplayName `
            -GivenName $FirtName `
            -Surname $LastName `
            -Path $OU `
            -City $City `
            -Company $Company `
            -OfficePhone $Phone `
            -Department $Department `
            -SamAccountName $Username `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) `
            -ChangePasswordAtLogon $true `
            -Enabled $true `
            -Description $Description


} 

