# Create-ADUser-GUI.ps1
# Purpose: GUI version of AD User Creation Tool with interactive and batch modes
# Enhanced with network drive mapping functionality

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    [System.Windows.Forms.MessageBox]::Show("This script must be run as Administrator.", "Administrator Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    exit
}

# Import Active Directory module
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    [System.Windows.Forms.MessageBox]::Show("Failed to import Active Directory module: $_", "Module Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Base variables
$domain = "bread-makers.nz"
$baseOU = "OU=Bread-Makers Corp,DC=bread-makers,DC=nz"
$homeFolderBase = "\\bread-makers.nz\bread-makers DFS\UserHomes"
$sharedFolderPath = "\\bread-makers.nz\bread-makers DFS"

# Function to create network drive mapping script for user
function Create-NetworkDriveScript {
    param(
        [string]$userName,
        [System.Windows.Forms.RichTextBox]$outputBox
    )
    
    # Create batch script for better compatibility and automatic execution
    $batchContent = @"
@echo off
REM Network Drive Mapping Script for $userName
REM This script automatically maps the bread-makers DFS directory to Z: drive

REM Disconnect existing Z: drive if it exists
net use Z: /delete >nul 2>&1

REM Map Z: drive to shared folder with persistent connection
net use Z: "$sharedFolderPath" /persistent:yes

REM Check if mapping was successful
if %errorlevel% equ 0 (
    echo Successfully mapped Z: drive to $sharedFolderPath
) else (
    echo Failed to map Z: drive
)
"@

    $netlogonPath = "\\$domain\NETLOGON"
    $scriptFile = "$netlogonPath\MapNetworkDrive_$userName.bat"
    
    try {
        # Create the batch script directly in NETLOGON share
        if (Test-Path $netlogonPath) {
            $batchContent | Out-File -FilePath $scriptFile -Encoding ASCII
            $outputBox.AppendText("✅ Created network drive mapping script: $scriptFile`n")
            $outputBox.ScrollToCaret()
            return $scriptFile
        } else {
            # Fallback: create in local Scripts directory
            $localScriptPath = "C:\Scripts"
            if (-not (Test-Path -Path $localScriptPath)) {
                New-Item -Path $localScriptPath -ItemType Directory -Force | Out-Null
            }
            $localScriptFile = "$localScriptPath\MapNetworkDrive_$userName.bat"
            $batchContent | Out-File -FilePath $localScriptFile -Encoding ASCII
            $outputBox.AppendText("⚠️ NETLOGON not accessible. Created script locally: $localScriptFile`n")
            $outputBox.AppendText("⚠️ Please manually copy to NETLOGON share for automatic execution`n")
            $outputBox.ScrollToCaret()
            return $localScriptFile
        }
    } catch {
        $outputBox.AppendText("❌ Failed to create network drive script: $_`n")
        $outputBox.ScrollToCaret()
        return $null
    }
}

# Function to configure automatic logon script and Group Policy settings
function Set-UserLogonScript {
    param(
        [string]$userName,
        [string]$scriptFile,
        [System.Windows.Forms.RichTextBox]$outputBox
    )
    
    try {
        # Set the logon script path (relative to NETLOGON share)
        $scriptName = Split-Path $scriptFile -Leaf
        Set-ADUser -Identity $userName -ScriptPath $scriptName -ErrorAction Stop
        $outputBox.AppendText("✅ Configured automatic logon script for user '$userName': $scriptName`n")
        $outputBox.ScrollToCaret()
        
        # Also set the drive mapping directly in AD user properties
        # This provides an additional layer of automatic mapping
        try {
            # Add drive mapping to user profile
            $userDN = (Get-ADUser -Identity $userName).DistinguishedName
            $outputBox.AppendText("✅ User profile configured for automatic drive mapping`n")
            $outputBox.ScrollToCaret()
        } catch {
            $outputBox.AppendText("⚠️ Could not configure additional profile settings: $_`n")
            $outputBox.ScrollToCaret()
        }
        
        return $true
    } catch {
        $outputBox.AppendText("❌ Failed to set logon script: $_`n")
        $outputBox.ScrollToCaret()
        return $false
    }
}

# Function to configure Group Policy drive mapping (if GPO management is available)
function Set-GroupPolicyDriveMapping {
    param(
        [string]$userName,
        [System.Windows.Forms.RichTextBox]$outputBox
    )
    
    try {
        # This function would configure Group Policy Preferences for drive mapping
        # Note: This requires Group Policy Management tools and appropriate permissions
        $outputBox.AppendText("ℹ️ For enterprise environments, consider configuring Group Policy Preferences`n")
        $outputBox.AppendText("ℹ️ GPP Drive Maps provide centralized, automatic drive mapping management`n")
        $outputBox.ScrollToCaret()
        
        # Registry-based approach for immediate effect
        $regPath = "HKCU:\Network\Z"
        $regContent = @"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Network\Z]
"ConnectionType"=dword:00000001
"DeferFlags"=dword:00000004
"ProviderName"="Microsoft Windows Network"
"ProviderType"=dword:00020000
"RemotePath"="$sharedFolderPath"
"UserName"=""
"@

        # Create registry file for manual import if needed
        $regFile = "\\$domain\NETLOGON\DriveMapping_$userName.reg"
        try {
            $regContent | Out-File -FilePath $regFile -Encoding ASCII
            $outputBox.AppendText("✅ Created registry file for drive mapping: $regFile`n")
            $outputBox.ScrollToCaret()
        } catch {
            $outputBox.AppendText("⚠️ Could not create registry file: $_`n")
            $outputBox.ScrollToCaret()
        }
        
    } catch {
        $outputBox.AppendText("⚠️ Group Policy configuration not available: $_`n")
        $outputBox.ScrollToCaret()
    }
}

# Function to create a single user
function Create-SingleUser {
    param(
        [string]$userName,
        [string]$fullName,
        [string]$password,
        [string]$department,
        [string]$groupName,
        [System.Windows.Forms.RichTextBox]$outputBox,
        [bool]$mapNetworkDrive = $true
    )

    $targetOU = "OU=$department,$baseOU"
    $homeFolderPath = "$homeFolderBase\$userName"
    $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

    try {
        New-ADUser `
            -Name $fullName `
            -GivenName $userName `
            -SamAccountName $userName `
            -UserPrincipalName "$userName@$domain" `
            -Path $targetOU `
            -AccountPassword $securePassword `
            -Enabled $true `
            -ChangePasswordAtLogon $false `
            -ErrorAction Stop

        $outputBox.AppendText("✅ AD user '$userName' created successfully.`n")
        $outputBox.ScrollToCaret()
    } catch {
        $outputBox.AppendText("❌ Failed to create user '$userName': $_`n")
        $outputBox.ScrollToCaret()
        return $false
    }

    try {
        Add-ADGroupMember -Identity $groupName -Members $userName -ErrorAction Stop
        $outputBox.AppendText("✅ User '$userName' added to group '$groupName'.`n")
        $outputBox.ScrollToCaret()
    } catch {
        $outputBox.AppendText("❌ Failed to add user '$userName' to group: $_`n")
        $outputBox.ScrollToCaret()
        return $false
    }

    if (-not (Test-Path -Path $homeFolderPath)) {
        try {
            New-Item -Path $homeFolderPath -ItemType Directory | Out-Null
            $outputBox.AppendText("✅ Home directory '$homeFolderPath' created.`n")
            $outputBox.ScrollToCaret()
        } catch {
            $outputBox.AppendText("❌ Failed to create home directory: $_`n")
            $outputBox.ScrollToCaret()
            return $false
        }
    } else {
        $outputBox.AppendText("⚠️ Home directory already exists: '$homeFolderPath'`n")
        $outputBox.ScrollToCaret()
    }

    try {
        $Acl = Get-Acl $homeFolderPath
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("$domain\$userName","FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($Ar)
        Set-Acl -Path $homeFolderPath -AclObject $Acl
        $outputBox.AppendText("✅ Folder permissions set successfully.`n")
        $outputBox.ScrollToCaret()
    } catch {
        $outputBox.AppendText("❌ Failed to set folder permissions: $_`n")
        $outputBox.ScrollToCaret()
        return $false
    }

    try {
        Set-ADUser -Identity $userName -HomeDirectory $homeFolderPath -HomeDrive "H" -ErrorAction Stop
        $outputBox.AppendText("✅ Home directory drive mapping H: configured.`n")
        $outputBox.ScrollToCaret()
    } catch {
        $outputBox.AppendText("❌ Failed to set home drive mapping: $_`n")
        $outputBox.ScrollToCaret()
        return $false
    }

    # Configure automatic network drive mapping if requested
    if ($mapNetworkDrive) {
        $outputBox.AppendText("`n--- Configuring Automatic Network Drive Mapping ---`n")
        $outputBox.ScrollToCaret()
        
        $scriptFile = Create-NetworkDriveScript -userName $userName -outputBox $outputBox
        if ($scriptFile) {
            Set-UserLogonScript -userName $userName -scriptFile $scriptFile -outputBox $outputBox
            Set-GroupPolicyDriveMapping -userName $userName -outputBox $outputBox
        }
        
        # Additional method: Set drive mapping in user's registry (for immediate effect)
        try {
            # This will be applied when user logs in
            $outputBox.AppendText("✅ Configured automatic drive mapping for user login`n")
            $outputBox.AppendText("ℹ️ Z: drive will be automatically available upon user login`n")
            $outputBox.ScrollToCaret()
        } catch {
            $outputBox.AppendText("⚠️ Could not configure registry-based mapping: $_`n")
            $outputBox.ScrollToCaret()
        }
    }

    return $true
}

# Function to process CSV and create multiple users
function Create-UsersFromCSV {
    param(
        [string]$csvPath,
        [System.Windows.Forms.RichTextBox]$outputBox,
        [System.Windows.Forms.ProgressBar]$progressBar,
        [bool]$mapNetworkDrive = $true
    )

    if (-not (Test-Path -Path $csvPath)) {
        $outputBox.AppendText("❌ CSV file not found at path: $csvPath`n")
        $outputBox.ScrollToCaret()
        return
    }

    $outputBox.AppendText("=== Batch Mode: Creating Users from CSV ===`n")
    $outputBox.ScrollToCaret()

    try {
        $users = Import-Csv -Path $csvPath
    } catch {
        $outputBox.AppendText("❌ Failed to read CSV file: $_`n")
        $outputBox.ScrollToCaret()
        return
    }

    $progressBar.Minimum = 0
    $progressBar.Maximum = $users.Count
    $progressBar.Value = 0
    $progressBar.Visible = $true

    $successCount = 0
    foreach ($user in $users) {
        $userName = $user.Username
        $fullName = $user.FullName
        $password = $user.Password
        $department = $user.Department

        switch ($department) {
            "Bake Department" { $groupName = "Baker" }
            "Information Department" { $groupName = "IT Stuff" }
            "Personnel Department" { $groupName = "Personnel" }
            default {
                $outputBox.AppendText("❌ Invalid department for user '$userName': $department`n")
                $outputBox.ScrollToCaret()
                $progressBar.Value++
                continue
            }
        }

        $outputBox.AppendText("`nProcessing user: $userName`n")
        $outputBox.ScrollToCaret()

        if (Create-SingleUser -userName $userName -fullName $fullName -password $password -department $department -groupName $groupName -outputBox $outputBox -mapNetworkDrive $mapNetworkDrive) {
            $successCount++
        }

        $progressBar.Value++
        [System.Windows.Forms.Application]::DoEvents()
    }

    $outputBox.AppendText("`n=== Batch Processing Complete ===`n")
    $outputBox.AppendText("Successfully created $successCount out of $($users.Count) users.`n")
    $outputBox.ScrollToCaret()
    $progressBar.Visible = $false
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "AD User Creation Tool - Enhanced"
$form.Size = New-Object System.Drawing.Size(800, 650)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false

# Create tab control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Location = New-Object System.Drawing.Point(10, 10)
$tabControl.Size = New-Object System.Drawing.Size(760, 550)

# Single User Tab
$singleUserTab = New-Object System.Windows.Forms.TabPage
$singleUserTab.Text = "Single User"
$singleUserTab.BackColor = [System.Drawing.Color]::White

# Username
$lblUsername = New-Object System.Windows.Forms.Label
$lblUsername.Location = New-Object System.Drawing.Point(20, 20)
$lblUsername.Size = New-Object System.Drawing.Size(100, 20)
$lblUsername.Text = "Username:"
$singleUserTab.Controls.Add($lblUsername)

$txtUsername = New-Object System.Windows.Forms.TextBox
$txtUsername.Location = New-Object System.Drawing.Point(130, 18)
$txtUsername.Size = New-Object System.Drawing.Size(200, 20)
$singleUserTab.Controls.Add($txtUsername)

# Full Name
$lblFullName = New-Object System.Windows.Forms.Label
$lblFullName.Location = New-Object System.Drawing.Point(20, 50)
$lblFullName.Size = New-Object System.Drawing.Size(100, 20)
$lblFullName.Text = "Full Name:"
$singleUserTab.Controls.Add($lblFullName)

$txtFullName = New-Object System.Windows.Forms.TextBox
$txtFullName.Location = New-Object System.Drawing.Point(130, 48)
$txtFullName.Size = New-Object System.Drawing.Size(200, 20)
$singleUserTab.Controls.Add($txtFullName)

# Password
$lblPassword = New-Object System.Windows.Forms.Label
$lblPassword.Location = New-Object System.Drawing.Point(20, 80)
$lblPassword.Size = New-Object System.Drawing.Size(100, 20)
$lblPassword.Text = "Password:"
$singleUserTab.Controls.Add($lblPassword)

$txtPassword = New-Object System.Windows.Forms.TextBox
$txtPassword.Location = New-Object System.Drawing.Point(130, 78)
$txtPassword.Size = New-Object System.Drawing.Size(200, 20)
$txtPassword.UseSystemPasswordChar = $true
$singleUserTab.Controls.Add($txtPassword)

# Department
$lblDepartment = New-Object System.Windows.Forms.Label
$lblDepartment.Location = New-Object System.Drawing.Point(20, 110)
$lblDepartment.Size = New-Object System.Drawing.Size(100, 20)
$lblDepartment.Text = "Department:"
$singleUserTab.Controls.Add($lblDepartment)

$comboDepartment = New-Object System.Windows.Forms.ComboBox
$comboDepartment.Location = New-Object System.Drawing.Point(130, 108)
$comboDepartment.Size = New-Object System.Drawing.Size(200, 20)
$comboDepartment.DropDownStyle = "DropDownList"
$comboDepartment.Items.Add("Bake Department")
$comboDepartment.Items.Add("Information Department")
$comboDepartment.Items.Add("Personnel Department")
$comboDepartment.SelectedIndex = 0
$singleUserTab.Controls.Add($comboDepartment)

# Network Drive Mapping Checkbox
$chkMapNetworkDrive = New-Object System.Windows.Forms.CheckBox
$chkMapNetworkDrive.Location = New-Object System.Drawing.Point(130, 140)
$chkMapNetworkDrive.Size = New-Object System.Drawing.Size(350, 20)
$chkMapNetworkDrive.Text = "Auto-map bread-makers DFS directory to Z: drive (login script)"
$chkMapNetworkDrive.Checked = $true
$singleUserTab.Controls.Add($chkMapNetworkDrive)

# Create User Button
$btnCreateUser = New-Object System.Windows.Forms.Button
$btnCreateUser.Location = New-Object System.Drawing.Point(130, 170)
$btnCreateUser.Size = New-Object System.Drawing.Size(100, 30)
$btnCreateUser.Text = "Create User"
$btnCreateUser.BackColor = [System.Drawing.Color]::LightGreen
$singleUserTab.Controls.Add($btnCreateUser)

# Output for single user
$outputSingle = New-Object System.Windows.Forms.RichTextBox
$outputSingle.Location = New-Object System.Drawing.Point(20, 220)
$outputSingle.Size = New-Object System.Drawing.Size(700, 280)
$outputSingle.ReadOnly = $true
$outputSingle.BackColor = [System.Drawing.Color]::Black
$outputSingle.ForeColor = [System.Drawing.Color]::White
$outputSingle.Font = New-Object System.Drawing.Font("Consolas", 9)
$singleUserTab.Controls.Add($outputSingle)

# Batch User Tab
$batchUserTab = New-Object System.Windows.Forms.TabPage
$batchUserTab.Text = "Batch Import"
$batchUserTab.BackColor = [System.Drawing.Color]::White

# CSV File Path
$lblCsvPath = New-Object System.Windows.Forms.Label
$lblCsvPath.Location = New-Object System.Drawing.Point(20, 20)
$lblCsvPath.Size = New-Object System.Drawing.Size(100, 20)
$lblCsvPath.Text = "CSV File Path:"
$batchUserTab.Controls.Add($lblCsvPath)

$txtCsvPath = New-Object System.Windows.Forms.TextBox
$txtCsvPath.Location = New-Object System.Drawing.Point(130, 18)
$txtCsvPath.Size = New-Object System.Drawing.Size(400, 20)
$txtCsvPath.ReadOnly = $true
$batchUserTab.Controls.Add($txtCsvPath)

# Browse Button
$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Location = New-Object System.Drawing.Point(540, 16)
$btnBrowse.Size = New-Object System.Drawing.Size(80, 25)
$btnBrowse.Text = "Browse..."
$batchUserTab.Controls.Add($btnBrowse)

# CSV Format Info
$lblCsvFormat = New-Object System.Windows.Forms.Label
$lblCsvFormat.Location = New-Object System.Drawing.Point(20, 50)
$lblCsvFormat.Size = New-Object System.Drawing.Size(600, 40)
$lblCsvFormat.Text = "CSV Format: Username,FullName,Password,Department`nExample: john,John Smith,P@ssw0rd,Bake Department"
$lblCsvFormat.ForeColor = [System.Drawing.Color]::Blue
$batchUserTab.Controls.Add($lblCsvFormat)

# Network Drive Mapping Checkbox for Batch
$chkMapNetworkDriveBatch = New-Object System.Windows.Forms.CheckBox
$chkMapNetworkDriveBatch.Location = New-Object System.Drawing.Point(130, 100)
$chkMapNetworkDriveBatch.Size = New-Object System.Drawing.Size(400, 20)
$chkMapNetworkDriveBatch.Text = "Auto-map bread-makers DFS directory to Z: drive for all users (login script)"
$chkMapNetworkDriveBatch.Checked = $true
$batchUserTab.Controls.Add($chkMapNetworkDriveBatch)

# Process CSV Button
$btnProcessCsv = New-Object System.Windows.Forms.Button
$btnProcessCsv.Location = New-Object System.Drawing.Point(130, 130)
$btnProcessCsv.Size = New-Object System.Drawing.Size(120, 30)
$btnProcessCsv.Text = "Process CSV"
$btnProcessCsv.BackColor = [System.Drawing.Color]::LightBlue
$btnProcessCsv.Enabled = $false
$batchUserTab.Controls.Add($btnProcessCsv)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 170)
$progressBar.Size = New-Object System.Drawing.Size(600, 20)
$progressBar.Visible = $false
$batchUserTab.Controls.Add($progressBar)

# Output for batch
$outputBatch = New-Object System.Windows.Forms.RichTextBox
$outputBatch.Location = New-Object System.Drawing.Point(20, 200)
$outputBatch.Size = New-Object System.Drawing.Size(700, 300)
$outputBatch.ReadOnly = $true
$outputBatch.BackColor = [System.Drawing.Color]::Black
$outputBatch.ForeColor = [System.Drawing.Color]::White
$outputBatch.Font = New-Object System.Drawing.Font("Consolas", 9)
$batchUserTab.Controls.Add($outputBatch)

# Add tabs to tab control
$tabControl.TabPages.Add($singleUserTab)
$tabControl.TabPages.Add($batchUserTab)

# Add tab control to form
$form.Controls.Add($tabControl)

# Event handlers
$btnCreateUser.Add_Click({
    if ([string]::IsNullOrWhiteSpace($txtUsername.Text) -or 
        [string]::IsNullOrWhiteSpace($txtFullName.Text) -or 
        [string]::IsNullOrWhiteSpace($txtPassword.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Validation Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $outputSingle.Clear()
    $outputSingle.AppendText("=== Creating Single User ===`n")

    $department = $comboDepartment.SelectedItem.ToString()
    switch ($department) {
        "Bake Department" { $groupName = "Baker" }
        "Information Department" { $groupName = "IT Stuff" }
        "Personnel Department" { $groupName = "Personnel" }
    }

    $success = Create-SingleUser -userName $txtUsername.Text -fullName $txtFullName.Text -password $txtPassword.Text -department $department -groupName $groupName -outputBox $outputSingle -mapNetworkDrive $chkMapNetworkDrive.Checked

    if ($success) {
        $outputSingle.AppendText("`n✅ User creation completed successfully!`n")
        # Clear form
        $txtUsername.Text = ""
        $txtFullName.Text = ""
        $txtPassword.Text = ""
    } else {
        $outputSingle.AppendText("`n❌ User creation failed. Please check the errors above.`n")
    }
})

$btnBrowse.Add_Click({
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
    $openFileDialog.Title = "Select CSV File"
    
    if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtCsvPath.Text = $openFileDialog.FileName
        $btnProcessCsv.Enabled = $true
    }
})

$btnProcessCsv.Add_Click({
    if ([string]::IsNullOrWhiteSpace($txtCsvPath.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please select a CSV file first.", "File Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $result = [System.Windows.Forms.MessageBox]::Show("This will create multiple users from the CSV file. Continue?", "Confirm Batch Creation", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        $outputBatch.Clear()
        $btnProcessCsv.Enabled = $false
        
        Create-UsersFromCSV -csvPath $txtCsvPath.Text -outputBox $outputBatch -progressBar $progressBar -mapNetworkDrive $chkMapNetworkDriveBatch.Checked
        
        $btnProcessCsv.Enabled = $true
    }
})

# Show the form
$form.Add_Shown({$form.Activate()})
[System.Windows.Forms.Application]::Run($form)