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
    
    $checkboxApps = New-Object System.Windows.Forms.CheckBox
    $checkboxApps.Text = "Backup installed applications"
    $checkboxApps.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxApps.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxApps)
    $yPosition += 30

    $checkboxLogs = New-Object System.Windows.Forms.CheckBox
    $checkboxLogs.Text = "Backup Windows logs"
    $checkboxLogs.Location = New-Object System.Drawing.Point(10, $yPosition)
    $checkboxLogs.Size = New-Object System.Drawing.Size(250, 20)
    $form.Controls.Add($checkboxLogs)
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

    $fileTypes = @(
        'Documents (*.doc, *.docx, *.pdf, *.txt, *.rtf, *.odt, *.xls, *.xlsx, *.ppt, *.pptx, *.epub, *.md, *.csv, *.tex, *.html, *.xml)',
        'Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp, *.tiff, *.svg, *.heic, *.webp, *.ico, *.raw)',
        'Music (*.mp3, *.wav, *.flac, *.aac, *.ogg, *.wma, *.m4a, *.aiff, *.alac, *.midi)',
        'Videos (*.mp4, *.avi, *.mkv, *.mov, *.wmv, *.flv, *.mpeg, *.3gp, *.webm, *.m4v)',
        'Archives (*.zip, *.rar, *.7z, *.tar, *.gz, *.bz2, *.iso, *.tgz, *.xz, *.lzma)',
        'Scripts (*.ps1, *.sh, *.py, *.js, *.rb, *.bat, *.cmd, *.vbs, *.php, *.pl, *.r, *.lua, *.ts, *.json, *.yaml, *.yml)',
        'Databases (*.sql, *.db, *.sqlite, *.accdb, *.mdb, *.dbf, *.pdb, *.kdbx, *.xml, *.json)',
        'Executables (*.exe, *.msi, *.bin, *.dll, *.app, *.apk, *.bat, *.cmd)',
        'Others (*.log, *.ini, *.cfg, *.bak, *.tmp, *.dat, *.cache, *.tmp, *.dmp, *.torrent)'
    )
    $fileTypeCheckboxes = @()
    $yFileTypePosition = 190
    foreach ($fileType in $fileTypes) {
        $fileTypeCheckbox = New-Object System.Windows.Forms.CheckBox
        $fileTypeCheckbox.Text = $fileType
        $fileTypeCheckbox.Location = New-Object System.Drawing.Point(300, $yFileTypePosition)
        $fileTypeCheckbox.Size = New-Object System.Drawing.Size(360, 40)
        $form.Controls.Add($fileTypeCheckbox)
        $fileTypeCheckboxes += $fileTypeCheckbox
        $yFileTypePosition += 40
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
        $backupGPO = $checkboxGPO.Checked
        $backupRegistry = $checkboxRegistry.Checked
        $backupPrinters = $checkboxPrinters.Checked
        $backupDrivers = $checkboxDrivers.Checked
        $backupPSTFiles = $checkboxPSTFiles.Checked
        $backupSerialNumbers = $checkboxSerialNumbers.Checked
        $backupApps = $checkboxApps.Checked
        $backupLogs = $checkboxLogs.Checked

        if (-not ($selectedUsers -or $backupGPO -or $backupRegistry -or $backupPrinters -or $backupDrivers -or $backupPSTFiles -or $backupSerialNumbers -or $backupApps -or $backupLogs)) {
            $logLabel.Text = "Please select at least one profile or one backup option."
            return
        }

        $backupFullProfile = $checkboxFullProfile.Checked
        if ($selectedUsers -and -not $backupFullProfile) {
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
                $totalFiles += (Get-ChildItem -Path $sourcePath -Recurse -Force -ErrorAction SilentlyContinue).Count
            } else {
                foreach ($fileType in $selectedFileTypes) {
                    $fileTypePatterns = switch ($fileType.Text) {
                        'Documents (*.doc, *.docx, *.pdf, *.txt, *.rtf, *.odt, *.xls, *.xlsx, *.ppt, *.pptx, *.epub, *.md, *.csv, *.tex, *.html, *.xml)' { 
                            '*.doc', '*.docx', '*.pdf', '*.txt', '*.rtf', '*.odt', '*.xls', '*.xlsx', '*.ppt', '*.pptx', '*.epub', '*.md', '*.csv', '*.tex', '*.html', '*.xml' 
                        }
                        'Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp, *.tiff, *.svg, *.heic, *.webp, *.ico, *.raw)' { 
                            '*.jpg', '*.jpeg', '*.png', '*.gif', '*.bmp', '*.tiff', '*.svg', '*.heic', '*.webp', '*.ico', '*.raw' 
                        }
                        'Music (*.mp3, *.wav, *.flac, *.aac, *.ogg, *.wma, *.m4a, *.aiff, *.alac, *.midi)' { 
                            '*.mp3', '*.wav', '*.flac', '*.aac', '*.ogg', '*.wma', '*.m4a', '*.aiff', '*.alac', '*.midi' 
                        }
                        'Videos (*.mp4, *.avi, *.mkv, *.mov, *.wmv, *.flv, *.mpeg, *.3gp, *.webm, *.m4v)' { 
                            '*.mp4', '*.avi', '*.mkv', '*.mov', '*.wmv', '*.flv', '*.mpeg', '*.3gp', '*.webm', '*.m4v' 
                        }
                        'Archives (*.zip, *.rar, *.7z, *.tar, *.gz, *.bz2, *.iso, *.tgz, *.xz, *.lzma)' { 
                            '*.zip', '*.rar', '*.7z', '*.tar', '*.gz', '*.bz2', '*.iso', '*.tgz', '*.xz', '*.lzma' 
                        }
                        'Scripts (*.ps1, *.sh, *.py, *.js, *.rb, *.bat, *.cmd, *.vbs, *.php, *.pl, *.r, *.lua, *.ts, *.json, *.yaml, *.yml)' { 
                            '*.ps1', '*.sh', '*.py', '*.js', '*.rb', '*.bat', '*.cmd', '*.vbs', '*.php', '*.pl', '*.r', '*.lua', '*.ts', '*.json', '*.yaml', '*.yml' 
                        }
                        'Databases (*.sql, *.db, *.sqlite, *.accdb, *.mdb, *.dbf, *.pdb, *.kdbx, *.xml, *.json)' { 
                            '*.sql', '*.db', '*.sqlite', '*.accdb', '*.mdb', '*.dbf', '*.pdb', '*.kdbx', '*.xml', '*.json' 
                        }
                        'Executables (*.exe, *.msi, *.bin, *.dll, *.app, *.apk, *.bat, *.cmd)' { 
                            '*.exe', '*.msi', '*.bin', '*.dll', '*.app', '*.apk', '*.bat', '*.cmd' 
                        }
                        'Others (*.log, *.ini, *.cfg, *.bak, *.tmp, *.dat, *.cache, *.tmp, *.dmp, *.torrent)' { 
                            '*.log', '*.ini', '*.cfg', '*.bak', '*.tmp', '*.dat', '*.cache', '*.tmp', '*.dmp', '*.torrent' 
                        }
                    }
                }
            }
        }

        if ($totalFiles -eq 0 -and -not ($backupGPO -or $backupRegistry -or $backupPrinters -or $backupDrivers -or $backupPSTFiles -or $backupSerialNumbers -or $backupApps -or $backupLogs)) {
            $logLabel.Text = "No files found for the selected profiles and file types, and no other backup options selected."
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
                Get-ChildItem -Path $sourcePath -Recurse -Force -ErrorAction SilentlyContinue | ForEach-Object {
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
                        'Documents (*.doc, *.docx, *.pdf, *.txt, *.rtf, *.odt, *.xls, *.xlsx, *.ppt, *.pptx, *.epub, *.md, *.csv, *.tex, *.html, *.xml)' { 
                            '*.doc', '*.docx', '*.pdf', '*.txt', '*.rtf', '*.odt', '*.xls', '*.xlsx', '*.ppt', '*.pptx', '*.epub', '*.md', '*.csv', '*.tex', '*.html', '*.xml' 
                        }
                        'Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp, *.tiff, *.svg, *.heic, *.webp, *.ico, *.raw)' { 
                            '*.jpg', '*.jpeg', '*.png', '*.gif', '*.bmp', '*.tiff', '*.svg', '*.heic', '*.webp', '*.ico', '*.raw' 
                        }
                        'Music (*.mp3, *.wav, *.flac, *.aac, *.ogg, *.wma, *.m4a, *.aiff, *.alac, *.midi)' { 
                            '*.mp3', '*.wav', '*.flac', '*.aac', '*.ogg', '*.wma', '*.m4a', '*.aiff', '*.alac', '*.midi' 
                        }
                        'Videos (*.mp4, *.avi, *.mkv, *.mov, *.wmv, *.flv, *.mpeg, *.3gp, *.webm, *.m4v)' { 
                            '*.mp4', '*.avi', '*.mkv', '*.mov', '*.wmv', '*.flv', '*.mpeg', '*.3gp', '*.webm', '*.m4v' 
                        }
                        'Archives (*.zip, *.rar, *.7z, *.tar, *.gz, *.bz2, *.iso, *.tgz, *.xz, *.lzma)' { 
                            '*.zip', '*.rar', '*.7z', '*.tar', '*.gz', '*.bz2', '*.iso', '*.tgz', '*.xz', '*.lzma' 
                        }
                        'Scripts (*.ps1, *.sh, *.py, *.js, *.rb, *.bat, *.cmd, *.vbs, *.php, *.pl, *.r, *.lua, *.ts, *.json, *.yaml, *.yml)' { 
                            '*.ps1', '*.sh', '*.py', '*.js', '*.rb', '*.bat', '*.cmd', '*.vbs', '*.php', '*.pl', '*.r', '*.lua', '*.ts', '*.json', '*.yaml', '*.yml' 
                        }
                        'Databases (*.sql, *.db, *.sqlite, *.accdb, *.mdb, *.dbf, *.pdb, *.kdbx, *.xml, *.json)' { 
                            '*.sql', '*.db', '*.sqlite', '*.accdb', '*.mdb', '*.dbf', '*.pdb', '*.kdbx', '*.xml', '*.json' 
                        }
                        'Executables (*.exe, *.msi, *.bin, *.dll, *.app, *.apk, *.bat, *.cmd)' { 
                            '*.exe', '*.msi', '*.bin', '*.dll', '*.app', '*.apk', '*.bat', '*.cmd' 
                        }
                        'Others (*.log, *.ini, *.cfg, *.bak, *.tmp, *.dat, *.cache, *.tmp, *.dmp, *.torrent)' { 
                            '*.log', '*.ini', '*.cfg', '*.bak', '*.tmp', '*.dat', '*.cache', '*.tmp', '*.dmp', '*.torrent' 
                        }
                    }

                    foreach ($pattern in $fileTypePatterns) {
                        Get-ChildItem -Path $sourcePath -Recurse -Filter $pattern -Force -ErrorAction SilentlyContinue | ForEach-Object {
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

        # Backup the list of installed applications if selected
        if ($checkboxApps.Checked) {
            $appsWindows = @()
            $appsOthers = @()

            # 1. Applications installées à partir du registre
            $registryApps = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Select-Object DisplayName, InstallDate, Publisher, DisplayVersion |
                Where-Object { $_.DisplayName -and $_.DisplayName -notmatch "^(Microsoft|Windows)" }
            $appsWindows += $registryApps

            # 2. Applications installées via WMI
            $wmiApps = Get-WmiObject -Query "SELECT * FROM Win32_Product" |
                Select-Object Name, InstallDate, Vendor, Version |
                Where-Object { $_.Name -and $_.Name -notmatch "^(Microsoft|Windows)" } |
                ForEach-Object {
                    New-Object PSObject -Property @{
                        DisplayName = $_.Name
                        InstallDate = $_.InstallDate
                        Publisher = $_.Vendor
                        DisplayVersion = $_.Version
                    }
                }
            $appsWindows += $wmiApps

            # 3. Applications de l'utilisateur actuel (si existant)
            $currentUserApps = Get-ItemProperty HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*, HKCU:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* |
                Select-Object DisplayName, InstallDate, Publisher, DisplayVersion |
                Where-Object { $_.DisplayName -and $_.DisplayName -notmatch "^(Microsoft|Windows)" }
            $appsWindows += $currentUserApps

            # 4. Packages installés via Get-Package
            $packageApps = Get-Package |
                Select-Object Name, ProviderName, Version |
                ForEach-Object {
                    New-Object PSObject -Property @{
                        DisplayName = $_.Name
                        InstallDate = ""
                        Publisher = $_.ProviderName
                        DisplayVersion = $_.Version
                    }
                }
            $appsWindows += $packageApps

            # 5. Applications installées dans Program Files
            $programFilesPaths = @("C:\Program Files", "C:\Program Files (x86)")
            foreach ($path in $programFilesPaths) {
                $programFilesApps = Get-ChildItem -Path $path -Directory | Select-Object Name, FullName |
                    ForEach-Object {
                        New-Object PSObject -Property @{
                            DisplayName = $_.Name
                            InstallDate = ""
                            Publisher = "Unknown"
                            DisplayVersion = ""
                            Path = $_.FullName
                        }
                    }
                $appsOthers += $programFilesApps
            }

            # 6. Applications installées dans AppData
            $appDataPath = [System.Environment]::GetFolderPath("ApplicationData")
            $appDataLocalPath = [System.Environment]::GetFolderPath("LocalApplicationData")
            $appDataApps = Get-ChildItem -Path $appDataPath, $appDataLocalPath -Directory | Select-Object Name, FullName |
                ForEach-Object {
                    New-Object PSObject -Property @{
                        DisplayName = $_.Name
                        InstallDate = ""
                        Publisher = "Unknown"
                        DisplayVersion = ""
                        Path = $_.FullName
                    }
                }
            $appsOthers += $appDataApps

            # Supprimer les doublons basés sur DisplayName et DisplayVersion
            $appsWindows = $appsWindows | Sort-Object DisplayName, DisplayVersion -Unique
            $appsOthers = $appsOthers | Sort-Object DisplayName, Path -Unique

            # Enregistrer les applications dans un fichier CSV unique avec séparation
            $appsCsvFile = Join-Path -Path $backupPath -ChildPath "installed_apps.csv"

            # Créer l'en-tête CSV
            "Source,DisplayName,InstallDate,Publisher,DisplayVersion,Path" | Out-File -FilePath $appsCsvFile -Encoding utf8

            # Ajouter les applications de Program Files en premier
            foreach ($app in $appsOthers) {
                "Program Files,$($app.DisplayName),$($app.InstallDate),$($app.Publisher),$($app.DisplayVersion),$($app.Path)" | Out-File -FilePath $appsCsvFile -Append -Encoding utf8
            }

            # Ajouter une ligne vide pour la séparation
            "" | Out-File -FilePath $appsCsvFile -Append -Encoding utf8

            # Ajouter les applications du registre et autres
            foreach ($app in $appsWindows) {
                "Registry,$($app.DisplayName),$($app.InstallDate),$($app.Publisher),$($app.DisplayVersion)," | Out-File -FilePath $appsCsvFile -Append -Encoding utf8
            }

            # Ajouter une ligne vide pour la séparation
            "" | Out-File -FilePath $appsCsvFile -Append -Encoding utf8

            # Ajouter les applications trouvées dans AppData
            foreach ($app in $appsOthers) {
                if ($app.Path -like "*AppData*") {
                    "AppData,$($app.DisplayName),$($app.InstallDate),$($app.Publisher),$($app.DisplayVersion),$($app.Path)" | Out-File -FilePath $appsCsvFile -Append -Encoding utf8
                }
            }

            Add-Content -Path $logFile -Value "Installed applications list backed up successfully."
        }

        # Backup Windows logs if selected
        if ($checkboxLogs.Checked) {
            try {
                $logsBackupPath = Join-Path -Path $backupPath -ChildPath "WindowsLogs"
                if (-not (Test-Path -Path $logsBackupPath)) {
                    New-Item -ItemType Directory -Path $logsBackupPath -Force
                }
                $eventLogs = Get-WinEvent -ListLog *
                foreach ($log in $eventLogs) {
                    $logFile = Join-Path -Path $logsBackupPath -ChildPath "$($log.LogName).evtx"
                    wevtutil epl $log.LogName $logFile
                }
                Add-Content -Path $logFile -Value "Windows logs backed up successfully."
            } catch {
                $logLabel.Text = "Error backing up Windows logs: $_"
                Add-Content -Path $logFile -Value "Error backing up Windows logs: $_"
            }
        }

        
        
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
                
                # Get the list of printers with detailed information
                $printers = Get-Printer | Select-Object Name, DriverName, PortName, Location, Comment, Shared, ShareName, Published, Type, DeviceID, PrinterStatus, Status, Default, PrintProcessor
                $printersFile = Join-Path -Path $printersBackupPath -ChildPath "printers.txt"
                $printers | Format-Table -AutoSize | Out-String | Set-Content -Path $printersFile
                Add-Content -Path $logFile -Value "Printers list backed up successfully."

                # Get the list of printer drivers
                $drivers = Get-PrinterDriver | Select-Object Name, Manufacturer, Version
                $driversFile = Join-Path -Path $printersBackupPath -ChildPath "drivers.txt"
                $drivers | Format-Table -AutoSize | Out-String | Set-Content -Path $driversFile
                Add-Content -Path $logFile -Value "Printer drivers backed up successfully."

                # Export printer drivers
                $driversBackupPath = Join-Path -Path $printersBackupPath -ChildPath "Drivers"
                if (-not (Test-Path -Path $driversBackupPath)) {
                    New-Item -ItemType Directory -Path $driversBackupPath -Force
                }

                $driverFound = $false
                foreach ($driver in $drivers) {
                    # Find the corresponding inf files for the driver
                    $driverInfFiles = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.ClassGuid -eq "{4d36e979-e325-11ce-bfc1-08002be10318}" -and $_.DriverName -eq $driver.Name } | Select-Object -ExpandProperty InfName -Unique
                    if ($driverInfFiles) {
                        $driverFound = $true
                        foreach ($infFile in $driverInfFiles) {
                            $infFilePath = Join-Path -Path "C:\Windows\INF" -ChildPath $infFile
                            if (Test-Path -Path $infFilePath) {
                                $driverBackupDir = Join-Path -Path $driversBackupPath -ChildPath ([System.IO.Path]::GetFileNameWithoutExtension($infFile))
                                if (-not (Test-Path -Path $driverBackupDir)) {
                                    New-Item -ItemType Directory -Path $driverBackupDir -Force
                                }
                                Start-Process -FilePath "pnputil.exe" -ArgumentList "/export-driver $infFilePath $driverBackupDir" -NoNewWindow -Wait
                            } else {
                                Add-Content -Path $logFile -Value "Driver file not found: $infFilePath"
                            }
                        }
                    }
                }

                if (-not $driverFound) {
                    Add-Content -Path $logFile -Value "No printer drivers found to back up."
                    $logLabel.Text = "No printer drivers found to back up."
                } else {
                    Add-Content -Path $logFile -Value "Printer drivers exported successfully."
                }
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
