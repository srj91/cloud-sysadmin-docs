This can be use full in scenarios where there is an intermittent sql connection issues and there are no error logged on the SQL server.

You can also create scheduled task to trigger this-> Even if the user is logged in or not it will run.
For optimization modify sleep parameter accordingly.

Note: 
1) Creates a text file to log if there is any error
2) While loop runs continuously and sleeps for defined times for optimization

While($true)
{
    function Test-SQLConnection
    {    
        [OutputType([bool])]
        Param
        (
            [Parameter(Mandatory=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position=0)]
            $ConnectionString
        )
        try
        {
            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $ConnectionString;
            $sqlConnection.Open();
            $sqlConnection.Close();

            return $true;
        }
        catch
        {
            $err = $_.Exception
            write-output $err.Message
        }
    }


#Modify Connection String
$ConnectionStatus=Test-SQLConnection "Server=13.67.xxx.xx,1433; Database=check; Integrated Security=false;User ID=sqladmin;Password=xxxxx;MultipleActiveResultSets=True"

        if($ConnectionStatus -ne $true)
        {
        [string]$date=Get-Date
        $date + " $ConnectionStatus"|Out-File "c:\proloysqllog2.txt" -Append

        #If you want to send an email as soon as first error occurs keep Break in place to go out of the loop and send email
        #Break
        }
        Start-Sleep -Milliseconds 1

} 


<#Mail Veriables
$From = "proloy.saha@g7cr.in"
$EmailTo = "proloy.saha@g7cr.in"
$Subject = "Sql Error Alert: $((Get-Date).ToString())"
$body = "Hello,<br> </br>"
$body +="Sql Error Alert.<br> </br>"
$body += $date + " $ConnectionStatus"
$body += "<br> </br> G7CR Support <br> </br>"


$SMTPServer = "outlook.office365.com"
$SMTPPort = "587"


$Username = "proloy.saha@g7cr.in"
$Password ="xxxxxxx"

$securePassword = ConvertTo-SecureString $Password -AsPlainText -Force
$cred = New-Object PSCredential ($Username,$securePassword)

write-output "Sending Mail Now"
Send-MailMessage -From $From -to $EmailTo -Subject $Subject  -Body $body -SmtpServer $SMTPServer -port $SMTPPort -UseSsl -Credential $cred -BodyAsHtml        

#> 

