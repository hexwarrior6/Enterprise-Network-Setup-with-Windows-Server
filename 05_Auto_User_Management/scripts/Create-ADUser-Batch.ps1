# Create-ADUser-Batch.ps1
# Purpose: Create AD users interactively or from a CSV file (supports single and batch mode)

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "This script must be run as Administrator."
    Read-Host "`nPress Enter to exit"
    exit
}

# Import Active Directory module
Import-Module ActiveDirectory -ErrorAction Stop

# Base variables
$domain = "bread-makers.nz"
$baseOU = "OU=Bread-Makers Corp,DC=bread-makers,DC=nz"
$homeFolderBase = "\\bread-makers.nz\bread-makers DFS\UserHomes"

# Function to create a single user
function Create-SingleUser {
    param()

    Write-Host "`n=== Interactive Mode: Create Single User ===" -ForegroundColor Green

    $userName = Read-Host "Enter username (e.g., David)"
    $fullName = Read-Host "Enter full name (e.g., David Smith)"
    $password = Read-Host "Enter password" -AsSecureString
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

    Write-Host "`nSelect department number:"
    Write-Host "1. Bake Department (Group: Baker)"
    Write-Host "2. Information Department (Group: IT Stuff)"
    Write-Host "3. Personnel Department (Group: Personnel)"
    $departmentChoice = Read-Host "Enter choice (1/2/3)"

    switch ($departmentChoice) {
        1 {
            $department = "Bake Department"
            $groupName = "Baker"
        }
        2 {
            $department = "Information Department"
            $groupName = "IT Stuff"
        }
        3 {
            $department = "Personnel Department"
            $groupName = "Personnel"
        }
        default {
            Write-Error "Invalid department choice."
            Read-Host "`nPress Enter to exit"
            return
        }
    }

    $targetOU = "OU=$department,$baseOU"
    $homeFolderPath = "$homeFolderBase\$userName"

    try {
        New-ADUser `
            -Name $fullName `
            -GivenName $userName `
            -SamAccountName $userName `
            -UserPrincipalName "$userName@$domain" `
            -Path $targetOU `
            -AccountPassword $password `
            -Enabled $true `
            -ChangePasswordAtLogon $false `
            -ErrorAction Stop

        Write-Host "✅ AD user '$userName' created successfully." -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to create user: $_"
        return
    }

    try {
        Add-ADGroupMember -Identity $groupName -Members $userName -ErrorAction Stop
        Write-Host "✅ User added to group '$groupName'." -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to add user to group: $_"
        return
    }

    if (-not (Test-Path -Path $homeFolderPath)) {
        New-Item -Path $homeFolderPath -ItemType Directory | Out-Null
        Write-Host "✅ Home directory '$homeFolderPath' created." -ForegroundColor Green
    } else {
        Write-Host "⚠️ Home directory already exists: '$homeFolderPath'" -ForegroundColor Yellow
    }

    try {
        $Acl = Get-Acl $homeFolderPath
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$userName","FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($Ar)
        Set-Acl -Path $homeFolderPath -AclObject $Acl
        Write-Host "✅ Folder permissions set successfully." -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to set folder permissions: $_"
        return
    }

    try {
        Set-ADUser -Identity $userName -HomeDirectory $homeFolderPath -HomeDrive "Z" -ErrorAction Stop
        Write-Host "✅ Home directory drive mapping Z: configured." -ForegroundColor Green
    } catch {
        Write-Error "❌ Failed to set home drive mapping: $_"
        return
    }
}

# Function to process CSV and create multiple users
function Create-UsersFromCSV {
    param(
        [string]$csvPath
    )

    if (-not (Test-Path -Path $csvPath)) {
        Write-Error "❌ CSV file not found at path: $csvPath"
        return
    }

    Write-Host "`n=== Batch Mode: Creating Users from CSV ===" -ForegroundColor Green

    try {
        $users = Import-Csv -Path $csvPath
    } catch {
        Write-Error "❌ Failed to read CSV file: $_"
        return
    }

    foreach ($user in $users) {
        $userName = $user.Username
        $fullName = $user.FullName
        $password = ConvertTo-SecureString $user.Password -AsPlainText -Force
        $department = $user.Department

        switch ($department) {
            "Bake Department" { $groupName = "Baker" }
            "Information Department" { $groupName = "IT Stuff" }
            "Personnel Department" { $groupName = "Personnel" }
            default {
                Write-Error "❌ Invalid department for user '$userName': $department"
                continue
            }
        }

        $targetOU = "OU=$department,$baseOU"
        $homeFolderPath = "$homeFolderBase\$userName"

        try {
            New-ADUser `
                -Name $fullName `
                -GivenName $userName `
                -SamAccountName $userName `
                -UserPrincipalName "$userName@$domain" `
                -Path $targetOU `
                -AccountPassword $password `
                -Enabled $true `
                -ChangePasswordAtLogon $false `
                -ErrorAction Stop

            Write-Host "✅ AD user '$userName' created successfully." -ForegroundColor Green
        } catch {
            Write-Error "❌ Failed to create user '$userName': $_"
            continue
        }

        try {
            Add-ADGroupMember -Identity $groupName -Members $userName -ErrorAction Stop
            Write-Host "✅ User '$userName' added to group '$groupName'." -ForegroundColor Green
        } catch {
            Write-Error "❌ Failed to add user '$userName' to group: $_"
            continue
        }

        if (-not (Test-Path -Path $homeFolderPath)) {
            New-Item -Path $homeFolderPath -ItemType Directory | Out-Null
            Write-Host "✅ Home directory '$homeFolderPath' created." -ForegroundColor Green
        } else {
            Write-Host "⚠️ Home directory already exists: '$homeFolderPath'" -ForegroundColor Yellow
        }

        try {
            $Acl = Get-Acl $homeFolderPath
            $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$userName","FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
            $Acl.SetAccessRule($Ar)
            Set-Acl -Path $homeFolderPath -AclObject $Acl
            Write-Host "✅ Folder permissions set successfully." -ForegroundColor Green
        } catch {
            Write-Error "❌ Failed to set folder permissions for '$userName': $_"
            continue
        }

        try {
            Set-ADUser -Identity $userName -HomeDirectory $homeFolderPath -HomeDrive "Z" -ErrorAction Stop
            Write-Host "✅ Home directory drive mapping Z: configured." -ForegroundColor Green
        } catch {
            Write-Error "❌ Failed to set home drive mapping for '$userName': $_"
            continue
        }
    }
}

# Main menu
Write-Host "=== AD User Creation Tool ===" -ForegroundColor Green
Write-Host "1. Create a single user interactively"
Write-Host "2. Create users from CSV file"
$mode = Read-Host "Choose mode (1 or 2)"

switch ($mode) {
    1 {
        Create-SingleUser
    }
    2 {
        $csvPath = Read-Host "Enter the full path to your CSV file"
        Create-UsersFromCSV -csvPath $csvPath
    }
    default {
        Write-Error "Invalid option selected."
    }
}

Read-Host "`nPress Enter to exit"