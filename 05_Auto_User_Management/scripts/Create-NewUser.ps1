# Create-ADUser.ps1
# Purpose: Interactive script to create an AD user with home folder, permissions, and group membership

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Warning "This script must be run as Administrator."
    exit
}

# Import Active Directory module
Import-Module ActiveDirectory -ErrorAction Stop

# Base variables
$domain = "bread-makers.nz"
$baseOU = "OU=Bread-Makers Corp,DC=bread-makers,DC=nz"
$homeFolderBase = "\\bread-makers.nz\bread-makers DFS\UserHomes"

# Prompt for user info
Write-Host "=== Automated AD User Creation Tool ===" -ForegroundColor Green
$userName = Read-Host "Enter username (e.g., David)"
$fullName = Read-Host "Enter full name (e.g., David Smith)"
$password = Read-Host "Enter password" -AsSecureString
$plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))

# Department options
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
        exit
    }
}

# Target OU
$targetOU = "OU=$department,$baseOU"

# Home directory path
$homeFolderPath = "$homeFolderBase\$userName"

# Create AD user
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
}
catch {
    Write-Error "❌ Failed to create user: $_"
    exit
}

# Add user to group
try {
    Add-ADGroupMember -Identity $groupName -Members $userName -ErrorAction Stop
    Write-Host "✅ User added to group '$groupName'." -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to add user to group: $_"
    exit
}

# Create home directory
if (-not (Test-Path -Path $homeFolderPath)) {
    New-Item -Path $homeFolderPath -ItemType Directory | Out-Null
    Write-Host "✅ Home directory '$homeFolderPath' created." -ForegroundColor Green
} else {
    Write-Host "⚠️ Home directory already exists: '$homeFolderPath'" -ForegroundColor Yellow
}

# Set folder permissions
try {
    $Acl = Get-Acl $homeFolderPath
    $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$userName","FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $Acl.SetAccessRule($Ar)
    Set-Acl -Path $homeFolderPath -AclObject $Acl
    Write-Host "✅ Folder permissions set successfully." -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to set folder permissions: $_"
    exit
}

# Set AD home directory mapping
try {
    Set-ADUser -Identity $userName -HomeDirectory $homeFolderPath -HomeDrive "Z" -ErrorAction Stop
    Write-Host "✅ Home directory drive mapping Z: configured." -ForegroundColor Green
}
catch {
    Write-Error "❌ Failed to set home drive mapping: $_"
    exit
}

Write-Host "`n🎉 User '$userName' has been successfully created!" -ForegroundColor Cyan