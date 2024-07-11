Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Start-ProcessAsAdmin {
    if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)) {
        $messageBoxOptions = [System.Windows.Forms.MessageBoxOptions]::ServiceNotification
        [System.Windows.Forms.MessageBox]::Show("Please run this script as an administrator.", "Administrator Privileges Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning, [System.Windows.Forms.MessageBoxDefaultButton]::Button1, $messageBoxOptions)
        exit
    }
}

function Create-BackupGUI {
    Start-ProcessAsAdmin

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "User Profiles and Applications Backup"
    $form.Size = New-Object System.Drawing.Size(700, 850)
    $form.StartPosition = "CenterScreen"

    # Label for backup path
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Backup path:"
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(150, 20)
    $form.Controls.Add($label)

    # Textbox for entering the backup path
    $backupPathBox = New-Object System.Windows.Forms.TextBox
    $backupPathBox.Size = New-Object System.Drawing.Size(450, 20)
    $backupPathBox.Location = New-Object System.Drawing.Point(10, 35)
    $backupPathBox.Text = "C:\Backup"
    $form.Controls.Add($backupPathBox)

    # Radio buttons for selecting backup type (directory or ZIP file)
    $backupTypeGroup = New-Object System.Windows.Forms.GroupBox
    $backupTypeGroup.Text = "Select backup type"
    $backupTypeGroup.Location = New-Object System.Drawing.Point(10, 65)
    $backupTypeGroup.Size = New-Object System.Drawing.Size(550, 60)
    $form.Controls.Add($backupTypeGroup)

    $radioDir = New-Object System.Windows.Forms.RadioButton
    $radioDir.Text = "Directory"
    $radioDir.Location = New-Object System.Drawing.Point(10, 20)
    $radioDir.Size = New-Object System.Drawing.Size(100, 20)
    $radioDir.Checked = $true
    $backupTypeGroup.Controls.Add($radioDir)

    $radioZip = New-Object System.Windows.Forms.RadioButton
    $radioZip.Text = "ZIP File"
    $radioZip.Location = New-Object System.Drawing.Point(120, 20)
    $radioZip.Size = New-Object System.Drawing.Size(100, 20)
    $backupTypeGroup.Controls.Add($radioZip)

    # Button to select backup path
    $backupPathButton = New-Object System.Windows.Forms.Button
    $backupPathButton.Text = "Select Backup Path"
    $backupPathButton.Location = New-Object System.Drawing.Point(470, 32)
    $backupPathButton.Size = New-Object System.Drawing.Size(100, 25)
    $backupPathButton.Add_Click({
        if ($radioDir.Checked) {
            $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $backupPathBox.Text = $folderDialog.SelectedPath
            }
        } elseif ($radioZip.Checked) {
            $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
            $saveFileDialog.Filter = "ZIP files (*.zip)|*.zip"
            if ($saveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $backupPathBox.Text = $saveFileDialog.FileName
            }
        }
    })
    $form.Controls.Add($backupPathButton)

    # Label for user profiles
    $labelUsers = New-Object System.Windows.Forms.Label
    $labelUsers.Text = "Select profiles to backup:"
    $labelUsers.Location = New-Object System.Drawing.Point(10, 135)
    $labelUsers.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($labelUsers)

    # Add checkboxes for user profiles found in C:\Users
    $checkboxes = @()
    $users = Get-ChildItem -Path "C:\Users" | Where-Object { $_.PSIsContainer }
    $yPosition = 160
    foreach ($user in $users) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $user.Name
        $checkbox.Location = New-Object System.Drawing.Point(10, $yPosition)
        $checkbox.Size = New-Object System.Drawing.Size(250, 20)
        $form.Controls.Add($checkbox)
        $checkboxes += $checkbox
        $yPosition += 30
    }

    # Add checkboxes for additional backup options
    $checkboxGPO = New-Object System.Windows.Forms.CheckBox
    $checkboxGPO.Text = "Backup local GPOs"
    $checkboxGPO.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxGPO.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxGPO)
    $yPosition += 30

    $checkboxRegistry = New-Object System.Windows.Forms.CheckBox
    $checkboxRegistry.Text = "Backup registry keys"
    $checkboxRegistry.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxRegistry.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxRegistry)
    $yPosition += 30

    $checkboxPrinters = New-Object System.Windows.Forms.CheckBox
    $checkboxPrinters.Text = "Backup printers and drivers"
    $checkboxPrinters.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxPrinters.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxPrinters)
    $yPosition += 30

    $checkboxDrivers = New-Object System.Windows.Forms.CheckBox
    $checkboxDrivers.Text = "Backup Windows drivers"
    $checkboxDrivers.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxDrivers.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxDrivers)
    $yPosition += 30

    $checkboxPSTFiles = New-Object System.Windows.Forms.CheckBox
    $checkboxPSTFiles.Text = "Backup Office PST files"
    $checkboxPSTFiles.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxPSTFiles.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxPSTFiles)
    $yPosition += 30

    $checkboxSerialNumbers = New-Object System.Windows.Forms.CheckBox
    $checkboxSerialNumbers.Text = "Backup serial numbers"
    $checkboxSerialNumbers.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxSerialNumbers.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxSerialNumbers)
    $yPosition += 30

    # Add checkboxes for file types to backup
    $labelFileTypes = New-Object System.Windows.Forms.Label
    $labelFileTypes.Text = "Select file types to backup:"
    $labelFileTypes.Location = New-Object System.Drawing.Point(300, 135)
    $labelFileTypes.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($labelFileTypes)

    $checkboxFullProfile = New-Object System.Windows.Forms.CheckBox
    $checkboxFullProfile.Text = "Backup entire profile"
    $checkboxFullProfile.Location = New-Object System.Drawing.Point(300, 160)
    $checkboxFullProfile.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxFullProfile)

    $fileTypes = @('Documents (*.doc, *.docx, *.pdf)', 'Images (*.jpg, *.jpeg, *.png, *.gif)', 'Music (*.mp3, *.wav)', 'Videos (*.mp4, *.avi, *.mkv)', 'Archives (*.zip, *.rar, *.7z)', 'Scripts (*.ps1, *.sh, *.py, *.js, *.rb)')
    $fileTypeCheckboxes = @()
    $yFileTypePosition = 190
    foreach ($fileType in $fileTypes) {
        $fileTypeCheckbox = New-Object System.Windows.Forms.CheckBox
        $fileTypeCheckbox.Text = $fileType
        $fileTypeCheckbox.Location = New-Object System.Drawing.Point(300, $yFileTypePosition)
        $fileTypeCheckbox.Size = New-Object System.Drawing.Size(250, 20)
        $form.Controls.Add($fileTypeCheckbox)
        $fileTypeCheckboxes += $fileTypeCheckbox
        $yFileTypePosition += 30
    }

    $checkboxFullProfile.Add_CheckedChanged({
        if ($checkboxFullProfile.Checked) {
            foreach ($fileTypeCheckbox in $fileTypeCheckboxes) {
                $fileTypeCheckbox.Enabled = $false
            }
        } else {
            foreach ($fileTypeCheckbox in $fileTypeCheckboxes) {
                $fileTypeCheckbox.Enabled = $true
            }
        }
    })

    # Add a progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0
    $progressBar.Size = New-Object System.Drawing.Size(650, 20)
    $progressBar.Location = New-Object System.Drawing.Point(10, 600)
    $form.Controls.Add($progressBar)

    # Add a label to display logs and errors
    $logLabel = New-Object System.Windows.Forms.Label
    $logLabel.Size = New-Object System.Drawing.Size(650, 100)
    $logLabel.Location = New-Object System.Drawing.Point(10, 630)
    $logLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $form.Controls.Add($logLabel)

    # Add a button to start the backup
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "Start Backup"
    $okButton.Location = New-Object System.Drawing.Point(10, 750)
    $okButton.Size = New-Object System.Drawing.Size(150, 30)
    $form.Controls.Add($okButton)

    # Add a button to cancel the backup
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object System.Drawing.Point(170, 750)
    $cancelButton.Size = New-Object System.Drawing.Size(150, 30)
    $form.Controls.Add($cancelButton)

    # Variable to handle cancellation
    $cancelRequested = $false

    $cancelButton.Add_Click({
        $cancelRequested = $true
        Write-Host "Backup cancellation requested."
    })

    $okButton.Add_Click({
        $selectedUsers = $checkboxes | Where-Object { $_.Checked }
        if (-not $selectedUsers) {
            $logLabel.Text = "Please select at least one profile to backup."
            return
        }

        $backupFullProfile = $checkboxFullProfile.Checked
        if (-not $backupFullProfile) {
            $selectedFileTypes = $fileTypeCheckboxes | Where-Object { $_.Checked }
            if (-not $selectedFileTypes) {
                $logLabel.Text = "Please select at least one file type to backup."
                return
            }
        }

        $backupPath = $backupPathBox.Text
        $zipBackup = $radioZip.Checked

        if ($zipBackup -and (Test-Path $backupPath)) { Remove-Item $backupPath -Force }

        if (-not $zipBackup -and -not (Test-Path -Path $backupPath)) {
            try {
                New-Item -ItemType Directory -Path $backupPath -ErrorAction Stop
            } catch {
                $logLabel.Text = "Error creating backup directory: $_"
                return
            }
        }

        $totalFiles = 0
        $copiedFiles = 0

        foreach ($user in $selectedUsers) {
            $sourcePath = Join-Path -Path "C:\Users" -ChildPath $user.Text
            if ($backupFullProfile) {
                $totalFiles += (Get-ChildItem -Path $sourcePath -Recurse -ErrorAction SilentlyContinue).Count
            } else {
                foreach ($fileType in $selectedFileTypes) {
                    $fileTypePatterns = switch ($fileType.Text) {
                        'Documents (*.doc, *.docx, *.pdf)' { '*.doc', '*.docx', '*.pdf' }
                        'Images (*.jpg, *.jpeg, *.png, *.gif)' { '*.jpg', '*.jpeg', '*.png', '*.gif' }
                        'Music (*.mp3, *.wav)' { '*.mp3', '*.wav' }
                        'Videos (*.mp4, *.avi, *.mkv)' { '*.mp4', '*.avi', '*.mkv' }
                        'Archives (*.zip, *.rar, *.7z)' { '*.zip', '*.rar', '*.7z' }
                        'Scripts (*.ps1, *.sh, *.py, *.js, *.rb)' { '*.ps1', '*.sh', '*.py', '*.js', '*.rb' }
                    }
                    foreach ($pattern in $fileTypePatterns) {
                        $totalFiles += (Get-ChildItem -Path $sourcePath -Recurse -Filter $pattern -ErrorAction SilentlyContinue).Count
                    }
                }
            }
        }

        if ($totalFiles -eq 0) {
            $logLabel.Text = "No files found for the selected profiles and file types."
            return
        }

        $logFile = Join-Path -Path $backupPath -ChildPath "backup_log.txt"
        Add-Content -Path $logFile -Value "Backup start: $(Get-Date)"
        $logLabel.Text = "Backup started..."

        foreach ($user in $selectedUsers) {
            if ($cancelRequested) {
                Add-Content -Path $logFile -Value "Backup cancelled by user: $(Get-Date)"
                $logLabel.Text = "Backup cancelled."
                return
            }

            $sourcePath = Join-Path -Path "C:\Users" -ChildPath $user.Text
            if ($backupFullProfile) {
                Get-ChildItem -Path $sourcePath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    if ($cancelRequested) {
                        Add-Content -Path $logFile -Value "Backup cancelled by user: $(Get-Date)"
                        $logLabel.Text = "Backup cancelled."
                        return
                    }
                    try {
                        $destinationFilePath = $_.FullName.Replace($sourcePath, $backupPath)
                        if ($zipBackup) {
                            $zipFilePath = $destinationFilePath.Replace("C:\Temp", $backupPath)
                            $zipArchive = [System.IO.Compression.ZipFile]::Open($backupPath, [System.IO.Compression.ZipArchiveMode]::Update)
                            $zipArchive.CreateEntryFromFile($_.FullName, $zipFilePath)
                            $zipArchive.Dispose()
                        } else {
                            $destinationDir = Split-Path -Path $destinationFilePath -Parent
                            if (-not (Test-Path -Path $destinationDir)) {
                                New-Item -ItemType Directory -Path $destinationDir -Force
                            }
                            Copy-Item -Path $_.FullName -Destination $destinationFilePath -Force -ErrorAction Stop
                        }
                        $copiedFiles++
                        $progressValue = [math]::Round((($copiedFiles / $totalFiles) * 100), 0)
                        if ($progressValue -le $progressBar.Maximum) {
                            $progressBar.Value = $progressValue
                        }
                    } catch {
                        $logLabel.Text = "Error copying file: $_.FullName"
                        Add-Content -Path $logFile -Value "Error copying file: $_.FullName - $_"
                    }
                }
            } else {
                foreach ($fileType in $selectedFileTypes) {
                    $fileTypePatterns = switch ($fileType.Text) {
                        'Documents (*.doc, *.docx, *.pdf)' { '*.doc', '*.docx', '*.pdf' }
                        'Images (*.jpg, *.jpeg, *.png, *.gif)' { '*.jpg', '*.jpeg', '*.png', '*.gif' }
                        'Music (*.mp3, *.wav)' { '*.mp3', '*.wav' }
                        'Videos (*.mp4, *.avi, *.mkv)' { '*.mp4', '*.avi', '*.mkv' }
                        'Archives (*.zip, *.rar, *.7z)' { '*.zip', '*.rar', '*.7z' }
                        'Scripts (*.ps1, *.sh, *.py, *.js, *.rb)' { '*.ps1', '*.sh', '*.py', '*.js', '*.rb' }
                    }

                    foreach ($pattern in $fileTypePatterns) {
                        Get-ChildItem -Path $sourcePath -Recurse -Filter $pattern -ErrorAction SilentlyContinue | ForEach-Object {
                            if ($cancelRequested) {
                                Add-Content -Path $logFile -Value "Backup cancelled by user: $(Get-Date)"
                                $logLabel.Text = "Backup cancelled."
                                return
                            }
                            try {
                                $destinationFilePath = $_.FullName.Replace($sourcePath, $backupPath)
                                if ($zipBackup) {
                                    $zipFilePath = $destinationFilePath.Replace("C:\Temp", $backupPath)
                                    $zipArchive = [System.IO.Compression.ZipFile]::Open($backupPath, [System.IO.Compression.ZipArchiveMode]::Update)
                                    $zipArchive.CreateEntryFromFile($_.FullName, $zipFilePath)
                                    $zipArchive.Dispose()
                                } else {
                                    $destinationDir = Split-Path -Path $destinationFilePath -Parent
                                    if (-not (Test-Path -Path $destinationDir)) {
                                        New-Item -ItemType Directory -Path $destinationDir -Force
                                    }
                                    Copy-Item -Path $_.FullName -Destination $destinationFilePath -Force -ErrorAction Stop
                                }
                                $copiedFiles++
                                $progressValue = [math]::Round((($copiedFiles / $totalFiles) * 100), 0)
                                if ($progressValue -le $progressBar.Maximum) {
                                    $progressBar.Value = $progressValue
                                }
                            } catch {
                                $logLabel.Text = "Error copying file: $_.FullName"
                                Add-Content -Path $logFile -Value "Error copying file: $_.FullName - $_"
                            }
                        }
                    }
                }
            }

            Add-Content -Path $logFile -Value "Profile $($user.Text) backed up successfully."
        }

        if ($zipBackup) {
            Remove-Item "C:\Temp" -Recurse -Force
        }

        # Backup the list of installed applications
        $apps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Select-Object DisplayName, InstallDate, Publisher, DisplayVersion |
                Where-Object { $_.DisplayName -and $_.DisplayName -notmatch "^(Microsoft|Windows)" }
        $appsFile = Join-Path -Path $backupPath -ChildPath "installed_apps.txt"
        $apps | Format-Table -AutoSize | Out-String | Set-Content -Path $appsFile

        Add-Content -Path $logFile -Value "Installed applications list backed up successfully."

        # Backup local GPOs if selected
        if ($checkboxGPO.Checked) {
            try {
                $gpoBackupPath = Join-Path -Path $backupPath -ChildPath "LocalGPOs"
                if (-not (Test-Path -Path $gpoBackupPath)) {
                    New-Item -ItemType Directory -Path $gpoBackupPath -Force
                }
                Copy-Item -Path "C:\Windows\System32\GroupPolicy" -Destination $gpoBackupPath -Recurse -Force
                Add-Content -Path $logFile -Value "Local GPOs backed up successfully."
            } catch {
                $logLabel.Text = "Error backing up local GPOs: $_"
                Add-Content -Path $logFile -Value "Error backing up local GPOs: $_"
            }
        }

        # Backup registry keys if selected
        if ($checkboxRegistry.Checked) {
            try {
                $registryBackupPath = Join-Path -Path $backupPath -ChildPath "RegistryBackup"
                if (-not (Test-Path -Path $registryBackupPath)) {
                    New-Item -ItemType Directory -Path $registryBackupPath -Force
                }
                reg export HKLM $registryBackupPath\HKLM.reg
                reg export HKCU $registryBackupPath\HKCU.reg
                Add-Content -Path $logFile -Value "Registry keys backed up successfully."
            } catch {
                $logLabel.Text = "Error backing up registry keys: $_"
                Add-Content -Path $logFile -Value "Error backing up registry keys: $_"
            }
        }

        # Backup printers and drivers if selected
        if ($checkboxPrinters.Checked) {
            try {
                $printersBackupPath = Join-Path -Path $backupPath -ChildPath "PrintersBackup"
                if (-not (Test-Path -Path $printersBackupPath)) {
                    New-Item -ItemType Directory -Path $printersBackupPath -Force
                }
                $printers = Get-Printer | Select-Object Name, DriverName, PortName
                $printersFile = Join-Path -Path $printersBackupPath -ChildPath "printers.txt"
                $printers | Format-Table -AutoSize | Out-String | Set-Content -Path $printersFile
                Add-Content -Path $logFile -Value "Printers list backed up successfully."

                $drivers = Get-PrinterDriver | Select-Object Name, Manufacturer, Version
                $driversFile = Join-Path -Path $printersBackupPath -ChildPath "drivers.txt"
                $drivers | Format-Table -AutoSize | Out-String | Set-Content -Path $driversFile
                Add-Content -Path $logFile -Value "Printer drivers backed up successfully."
            } catch {
                $logLabel.Text = "Error backing up printers and drivers: $_"
                Add-Content -Path $logFile -Value "Error backing up printers and drivers: $_"
            }
        }

        # Backup Windows drivers if selected
        if ($checkboxDrivers.Checked) {
            try {
                $driversBackupPath = Join-Path -Path $backupPath -ChildPath "WindowsDrivers"
                if (-not (Test-Path -Path $driversBackupPath)) {
                    New-Item -ItemType Directory -Path $driversBackupPath -Force
                }
                Export-WindowsDriver -Online -Destination $driversBackupPath
                Add-Content -Path $logFile -Value "Windows drivers backed up successfully."
            } catch {
                $logLabel.Text = "Error backing up Windows drivers: $_"
                Add-Content -Path $logFile -Value "Error backing up Windows drivers: $_"
            }
        }

        # Backup Office PST files if selected
        if ($checkboxPSTFiles.Checked) {
            foreach ($user in $selectedUsers) {
                $pstFilesPath = Join-Path -Path "C:\Users" -ChildPath $user.Text -ChildPath "AppData\Local\Microsoft\Outlook"
                if (Test-Path $pstFilesPath) {
                    Get-ChildItem -Path $pstFilesPath -Filter "*.pst" -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                        if ($cancelRequested) {
                            Add-Content -Path $logFile -Value "Backup cancelled by user: $(Get-Date)"
                            $logLabel.Text = "Backup cancelled."
                            return
                        }
                        try {
                            $destinationFilePath = $_.FullName.Replace("C:\Users", $backupPath)
                            $destinationDir = Split-Path -Path $destinationFilePath -Parent
                            if (-not (Test-Path -Path $destinationDir)) {
                                New-Item -ItemType Directory -Path $destinationDir -Force
                            }
                            Copy-Item -Path $_.FullName -Destination $destinationFilePath -Force -ErrorAction Stop
                            Add-Content -Path $logFile -Value "PST file copied: $($_.FullName) to $destinationFilePath"
                        } catch {
                            $logLabel.Text = "Error copying PST file: $_.FullName"
                            Add-Content -Path $logFile -Value "Error copying PST file: $_.FullName - $_"
                        }
                    }
                }
            }
            Add-Content -Path $logFile -Value "Office PST files backed up successfully."
        }

        # Backup serial numbers if selected
        if ($checkboxSerialNumbers.Checked) {
            try {
                $serialNumbersFile = Join-Path -Path $backupPath -ChildPath "serial_numbers.txt"
                $serialNumbers = Get-WmiObject Win32_BIOS | Select-Object SerialNumber
                $serialNumbers | Format-Table -AutoSize | Out-String | Set-Content -Path $serialNumbersFile
                Add-Content -Path $logFile -Value "Serial numbers backed up successfully."
            } catch {
                $logLabel.Text = "Error backing up serial numbers: $_"
                Add-Content -Path $logFile -Value "Error backing up serial numbers: $_"
            }
        }

        $logLabel.Text = "Backup completed."
        $progressBar.Value = 100
        Add-Content -Path $logFile -Value "Backup end: $(Get-Date)"
    })

    # Show the form
    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

# Call the function to create the GUI
Create-BackupGUI
