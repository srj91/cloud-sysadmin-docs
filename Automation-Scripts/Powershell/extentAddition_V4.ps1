<# This PowerShell script performs the following operations:

- Reads a number from a text file (apprise.txt).
- Searches for this number in a structure file (apprise.st) and identifies the last line containing this number.
- Creates two new lines by incrementing the number part in the identified line and appends these lines to a new structure file.
- Creates a batch file with commands to add the new structure file to the database extents online and to list the updated structure of the database extents.
- Modifies proenv.bat to call the batch file with the Proenv commands and runs proenv.bat as an administrator.
- After the new extents are added, sends an email notification with the details of the newly added extents.
- This script is designed to be used with the Progress OpenEdge database and requires the prostrct utility. It should be run on the server where the database is located.
#>

# Database Apprise
$appriseTxtFile = "C:\Users\rgu\Downloads\Monitoring\Apprise.txt"
$appriseStFile = "D:\localrepo\Databases\Node01\apprise.st"
# Database Custom
$customTxtFile = "C:\Users\rgu\Downloads\Monitoring\Custom.txt"
$customStFile = "D:\localrepo\Databases\Node01\custom.st"

# Get the directory of the .st file
$directory = Split-Path -Path $appriseStFile

# Read the content of apprise.txt file and identify the number
$numberA = Get-Content -Path $appriseTxtFile | Select-String -Pattern "\d+" -AllMatches | ForEach-Object { $_.Matches.Value } | ForEach-Object { [int]$_ }
# Read the content of custom.txt file and identify the number
$numberC = Get-Content -Path $customTxtFile | Select-String -Pattern "\d+" -AllMatches | ForEach-Object { $_.Matches.Value } | ForEach-Object { [int]$_ }

# Function to generate extent files
function New-Extent {
    param (
        $number,
        $stFile
    )

    # Ensure the identified number is correct
    foreach ($identifiedNumber in $number){
        # Read the content of .st file
        $content = Get-Content -Path $stFile

        # Initialize variable to store the last line containing the identified number
        $lastMatchingLine = $null

        # Check BI file if needs to be added
        if ($identifiedNumber -eq 3) {
            foreach ($line in $content) {
                if ($line -match "\.b") {
                    $lastMatchingLine = $line
                }
            }
            # Check if a matching line was found
            if ($lastMatchingLine) {
                # Split the string on ".b"
                $parts = $lastMatchingLine -split "\.b"

                # Increment the number part
                $currNum = $parts[1] -split "f"
                $numberPart = [int]$currNum[0] + 1

                # Create the second line with the next incremented number
                $addLine_bi = $parts[0] + ".b" + $numberPart + " f 2048000"

                # Write the new line to the new file
                Add-Content -Path $newFilePath -Value $addLine_bi
            }
        }
        else {
                # Check .d file whether need to add new extent       
                # Iterate through each line to find lines containing the identified number
                foreach ($line in $content) {
                    if ($line -match "$identifiedNumber\.d\d+") {
                        $lastMatchingLine = $line
                    }
                }
                # Check if a matching line was found
                if ($lastMatchingLine) {
                    # Split the string on ".d"
                    $parts = $lastMatchingLine -split "\.d"

                    # Increment the number part
                    $numberPart = [int]$parts[1] + 1

                    # Join the parts back together and append "f 2048000"
                    $modifiedLine = $parts[0] + ".d" + $numberPart + " f 2048000"

                    # Create the second line with the next incremented number
                    $numberPart += 1
                    $secondLine = $parts[0] + ".d" + $numberPart

                    # Write the modified line and the second line to the new file
                    Add-Content -Path $newFilePath -Value $modifiedLine
                    Add-Content -Path $newFilePath -Value $secondLine 
                }
        }
    }
}

# Function to add new extent files
function Add-Extent {
    param (
        $databaseName
    )

    "New file created: $newFilePath"

    # Progress DLC path
    $progressDLCPath = "C:\Progress\OpenEdge12.2\bin\"

    # Create a new batch file to run the Proenv commands
    $batchFilePath = Join-Path -Path $directory -ChildPath "runProenvCommands_$databaseName.bat"
    $batchFileContent = @"
D:
cd $directory
call $progressDLCPath`prostrct addonline $databaseName $newFileName
call $progressDLCPath`prostrct list $databaseName
cmd
"@

    Set-Content -Path $batchFilePath -Value $batchFileContent
    # Run bat as an administrator
    Start-Process -FilePath $batchFilePath -Verb RunAs
}

# Function to check if Extent is added
function Find-Extent {
    param (
        $updatedStFile,
        $addedStFile
    )
    
    # Read the updated content of .st file
    $updatedContent = Get-Content -Path $updatedStFile
    # Read the added content of apprise.st file
    $addedContent = Get-Content -Path $addedStFile

    foreach($line in $addedContent) {
        if ($updatedContent.Contains($line)) {
            return $true
        } else {
            return $false
        }
    }
}

# Function to send emails after adding extents
function Send-Email {
    # After the new extents are added, send an email notification
    $smtpServer = "smtp.office365.com"  # Replace with your SMTP server
    $smtpPort = 587  # Replace with your SMTP port
    $smtpUser = "noreply@example.com"  # Replace with your SMTP username
    $smtpPassword = ConvertTo-SecureString "password" -AsPlainText -Force  # Replace with your SMTP password
    $smtpCredential = New-Object System.Management.Automation.PSCredential($smtpUser, $smtpPassword)

    $from = "noreply@example.com"  # Replace with your "from" email address
    $to = "ApteanOperations-AppriseSRE@aptean.com"  # Replace with your "to" email address
    $subject = "New extents added to database $databaseName on server $env:COMPUTERNAME"

    $body = @"
Hi Team,
    
Critical extents '$identifiedNumber' identified on server '$env:COMPUTERNAME' for database '$databaseName'.
Further process of adding new extent is completed. Please find the details as follows

Newly added extents are as below:
$(Get-Content -Path $newFilePath | Out-String)

Thanks,
Apprise Tech-Hub
"@

    Send-MailMessage -SmtpServer $smtpServer -Port $smtpPort -Credential $smtpCredential -From $from -To $to -Subject $subject -Body $body -UseSsl
}

if ($numberA) {
    # Generate the new file name
    $date = Get-Date -Format "yyyyMMddss"
    $newFileName = "apprise_${date}.st"
    $newFilePath = Join-Path -Path $directory -ChildPath $newFileName
    New-Extent -number $numberA -stFile $appriseStFile
    Add-Extent -databaseName "apprise"
    Write-Host "Waint 10 seconds for completeing excution..."
    Start-Sleep -Seconds 10
    $resultA = Find-Extent -updatedStFile $appriseStFile -addedStFile $newFilePath
    if ($resultA -eq $true) {
        Send-Email
    } else {
        "Add extent failed."
    }
} else {
    "No number found in the apprise.txt file."
}

if ($numberC) {
    # Generate the new file name
    $date = Get-Date -Format "yyyyMMddss"
    $newFileName = "custom_${date}.st"
    $newFilePath = Join-Path -Path $directory -ChildPath $newFileName
    New-Extent -number $numberC -stFile $customStFile
    Add-Extent -databaseName "custom" -filePath $newFilePath
    Write-Host "Waint 10 seconds for completeing excution..."
    Start-Sleep -Seconds 10
    $resultC = Find-Extent -updatedStFile $customStFile -addedStFile $newFilePath
    if ($resultC -eq $true) {
        Send-Email
    } else {
        "Add extent failed."
    }
} else {
    "No number found in the custom.txt file."
}

