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

function Add-Control {
    param (
        [string]$type,
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width,
        [int]$height,
        [System.Windows.Forms.Control]$parent
    )
    $control = New-Object ("System.Windows.Forms." + $type)
    $control.Text = $text
    $control.Location = New-Object System.Drawing.Point($x, $y)
    $control.Size = New-Object System.Drawing.Size($width, $height)
    $parent.Controls.Add($control)
    return $control
}

function Create-BackupRestoreGUI {
    Start-ProcessAsAdmin

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "User Profiles and Applications Backup and Restore"
    $form.Size = New-Object System.Drawing.Size(700, 900)
    $form.StartPosition = "CenterScreen"
    $form.AutoSize = $true
    $form.AutoSizeMode = "GrowAndShrink"

    $tabControl = New-Object System.Windows.Forms.TabControl
    $tabControl.Size = New-Object System.Drawing.Size(680, 850)
    $tabControl.Location = New-Object System.Drawing.Point(10, 10)
    $tabControl.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom

    $backupTab = New-Object System.Windows.Forms.TabPage
    $backupTab.Text = "Backup"

    $restoreTab = New-Object System.Windows.Forms.TabPage
    $restoreTab.Text = "Restore"

    $tabControl.TabPages.Add($backupTab)
    $tabControl.TabPages.Add($restoreTab)
    $form.Controls.Add($tabControl)

    # Backup Tab
    $label = Add-Control -type "Label" -text "Backup path:" -x 10 -y 10 -width 150 -height 20 -parent $backupTab
    $backupPathBox = Add-Control -type "TextBox" -text "C:\Backup" -x 10 -y 35 -width 450 -height 20 -parent $backupTab

    $backupTypeGroup = Add-Control -type "GroupBox" -text "Select backup type" -x 10 -y 65 -width 550 -height 60 -parent $backupTab
    $radioDir = Add-Control -type "RadioButton" -text "Directory" -x 10 -y 20 -width 100 -height 20 -parent $backupTypeGroup
    $radioDir.Checked = $true
    $radioZip = Add-Control -type "RadioButton" -text "ZIP File" -x 120 -y 20 -width 100 -height 20 -parent $backupTypeGroup

    $backupPathButton = Add-Control -type "Button" -text "Select Backup Path" -x 470 -y 32 -width 100 -height 25 -parent $backupTab
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

    $labelUsers = Add-Control -type "Label" -text "Select profiles to backup:" -x 10 -y 135 -width 250 -height 20 -parent $backupTab
    $checkboxes = @()
    $users = Get-ChildItem -Path "C:\Users" | Where-Object { $_.PSIsContainer }
    $yPosition = 160
    foreach ($user in $users) {
        $checkbox = Add-Control -type "CheckBox" -text $user.Name -x 10 -y $yPosition -width 250 -height 20 -parent $backupTab
        $checkboxes += $checkbox
        $yPosition += 30
    }

    $checkboxGPO = Add-Control -type "CheckBox" -text "Backup local GPOs" -x 10 -y $yPosition -width 250 -height 20 -parent $backupTab
    $yPosition += 30
    $checkboxRegistry = Add-Control -type "CheckBox" -text "Backup registry keys" -x 10 -y $yPosition -width 250 -height 20 -parent $backupTab
    $yPosition += 30
    $checkboxPrinters = Add-Control -type "CheckBox" -text "Backup printers and drivers" -x 10 -y $yPosition -width 250 -height 20 -parent $backupTab
    $yPosition += 30
    $checkboxDrivers = Add-Control -type "CheckBox" -text "Backup Windows drivers" -x 10 -y $yPosition -width 250 -height 20 -parent $backupTab
    $yPosition += 30
    $checkboxPSTFiles = Add-Control -type "CheckBox" -text "Backup Office PST files" -x 10 -y $yPosition -width 250 -height 20 -parent $backupTab
    $yPosition += 30
    $checkboxSerialNumbers = Add-Control -type "CheckBox" -text "Backup serial numbers" -x 10 -y $yPosition -width 250 -height 20 -parent $backupTab
    $yPosition += 30

    $labelFileTypes = Add-Control -type "Label" -text "Select file types to backup:" -x 300 -y 135 -width 250 -height 20 -parent $backupTab
    $checkboxFullProfile = Add-Control -type "CheckBox" -text "Backup entire profile" -x 300 -y 160 -width 250 -height 20 -parent $backupTab

    $fileTypes = @('Documents (*.doc, *.docx, *.pdf, *.txt, *.rtf, *.odt, *.xlsx, *.xls, *.ppt, *.pptx, *.csv, *.ods, *.odp)', 'Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp, *.tiff, *.tif, *.svg, *.ico, *.webp, *.heic)', 'Music (*.mp3, *.wav, *.flac, *.aac, *.ogg, *.wma, *.m4a, *.alac)', 'Videos (*.mp4, *.avi, *.mkv, *.mov, *.wmv, *.flv, *.mpeg, *.mpg, *.m4v, *.webm)', 'Archives (*.zip, *.rar, *.7z, *.tar, *.gz, *.bz2, *.xz, *.iso)', 'Scripts (*.ps1, *.sh, *.py, *.js, *.rb, *.bat, *.cmd, *.php, *.pl, *.vbs, *.java)', 'Executables (*.exe, *.msi, *.bat, *.cmd)', 'Database (*.sql, *.db, *.sqlite, *.accdb, *.mdb)', 'Ebooks (*.epub, *.mobi, *.azw, *.azw3, *.pdf)', 'CAD Files (*.dwg, *.dxf, *.dwt, *.dws)', 'Font Files (*.ttf, *.otf, *.woff, *.woff2)', 'Configuration Files (*.cfg, *.conf, *.ini, *.json, *.xml, *.yaml, *.yml)', 'Log Files (*.log, *.txt)')
    $fileTypeCheckboxes = @()
    $yFileTypePosition = 190
    foreach ($fileType in $fileTypes) {
        $fileTypeCheckbox = Add-Control -type "CheckBox" -text $fileType -x 300 -y $yFileTypePosition -width 250 -height 20 -parent $backupTab
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

    # Add a button to start the backup
    $okButton = Add-Control -type "Button" -text "Start Backup" -x 10 -y 700 -width 150 -height 30 -parent $backupTab
    $okButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

    # Add a button to cancel the backup
    $cancelButton = Add-Control -type "Button" -text "Cancel" -x 170 -y 700 -width 150 -height 30 -parent $backupTab
    $cancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

    # Add a progress bar
    $progressBar = Add-Control -type "ProgressBar" -text "" -x 10 -y 750 -width 650 -height 20 -parent $backupTab
    $progressBar.Minimum = 0
    $progressBar.Maximum = 100
    $progressBar.Value = 0

    # Add a label to display logs and errors
    $logLabel = Add-Control -type "Label" -text "" -x 10 -y 780 -width 650 -height 100 -parent $backupTab
    $logLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D

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
                        'Documents (*.doc, *.docx, *.pdf, *.txt, *.rtf, *.odt, *.xlsx, *.xls, *.ppt, *.pptx, *.csv, *.ods, *.odp)' { '*.doc', '*.docx', '*.pdf', '*.txt', '*.rtf', '*.odt', '*.xlsx', '*.xls', '*.ppt', '*.pptx', '*.csv', '*.ods', '*.odp' }
                        'Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp, *.tiff, *.tif, *.svg, *.ico, *.webp, *.heic)' { '*.jpg', '*.jpeg', '*.png', '*.gif', '*.bmp', '*.tiff', '*.tif', '*.svg', '*.ico', '*.webp', '*.heic' }
                        'Music (*.mp3, *.wav, *.flac, *.aac, *.ogg, *.wma, *.m4a, *.alac)' { '*.mp3', '*.wav', '*.flac', '*.aac', '*.ogg', '*.wma', '*.m4a', '*.alac' }
                        'Videos (*.mp4, *.avi, *.mkv, *.mov, *.wmv, *.flv, *.mpeg, *.mpg, *.m4v, *.webm)' { '*.mp4', '*.avi', '*.mkv', '*.mov', '*.wmv', '*.flv', '*.mpeg', '*.mpg', '*.m4v', '*.webm' }
                        'Archives (*.zip, *.rar, *.7z, *.tar, *.gz, *.bz2, *.xz, *.iso)' { '*.zip', '*.rar', '*.7z', '*.tar', '*.gz', '*.bz2', '*.xz', '*.iso' }
                        'Scripts (*.ps1, *.sh, *.py, *.js, *.rb, *.bat, *.cmd, *.php, *.pl, *.vbs, *.java)' { '*.ps1', '*.sh', '*.py', '*.js', '*.rb', '*.bat', '*.cmd', '*.php', '*.pl', '*.vbs', '*.java' }
                        'Executables (*.exe, *.msi, *.bat, *.cmd)' { '*.exe', '*.msi', '*.bat', '*.cmd' }
                        'Database (*.sql, *.db, *.sqlite, *.accdb, *.mdb)' { '*.sql', '*.db', '*.sqlite', '*.accdb', '*.mdb' }
                        'Ebooks (*.epub, *.mobi, *.azw, *.azw3, *.pdf)' { '*.epub', '*.mobi', '*.azw', '*.azw3', '*.pdf' }
                        'CAD Files (*.dwg, *.dxf, *.dwt, *.dws)' { '*.dwg', '*.dxf', '*.dwt', '*.dws' }
                        'Font Files (*.ttf, *.otf, *.woff, *.woff2)' { '*.ttf', '*.otf', '*.woff', '*.woff2' }
                        'Configuration Files (*.cfg, *.conf, *.ini, *.json, *.xml, *.yaml, *.yml)' { '*.cfg', '*.conf', '*.ini', '*.json', '*.xml', '*.yaml', '*.yml' }
                        'Log Files (*.log, *.txt)' { '*.log', '*.txt' }
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
                        'Documents (*.doc, *.docx, *.pdf, *.txt, *.rtf, *.odt, *.xlsx, *.xls, *.ppt, *.pptx, *.csv, *.ods, *.odp)' { '*.doc', '*.docx', '*.pdf', '*.txt', '*.rtf', '*.odt', '*.xlsx', '*.xls', '*.ppt', '*.pptx', '*.csv', '*.ods', '*.odp' }
                        'Images (*.jpg, *.jpeg, *.png, *.gif, *.bmp, *.tiff, *.tif, *.svg, *.ico, *.webp, *.heic)' { '*.jpg', '*.jpeg', '*.png', '*.gif', '*.bmp', '*.tiff', '*.tif', '*.svg', '*.ico', '*.webp', '*.heic' }
                        'Music (*.mp3, *.wav, *.flac, *.aac, *.ogg, *.wma, *.m4a, *.alac)' { '*.mp3', '*.wav', '*.flac', '*.aac', '*.ogg', '*.wma', '*.m4a', '*.alac' }
                        'Videos (*.mp4, *.avi, *.mkv, *.mov, *.wmv, *.flv, *.mpeg, *.mpg, *.m4v, *.webm)' { '*.mp4', '*.avi', '*.mkv', '*.mov', '*.wmv', '*.flv', '*.mpeg', '*.mpg', '*.m4v', '*.webm' }
                        'Archives (*.zip, *.rar, *.7z, *.tar, *.gz, *.bz2, *.xz, *.iso)' { '*.zip', '*.rar', '*.7z', '*.tar', '*.gz', '*.bz2', '*.xz', '*.iso' }
                        'Scripts (*.ps1, *.sh, *.py, *.js, *.rb, *.bat, *.cmd, *.php, *.pl, *.vbs, *.java)' { '*.ps1', '*.sh', '*.py', '*.js', '*.rb', '*.bat', '*.cmd', '*.php', '*.pl', '*.vbs', '*.java' }
                        'Executables (*.exe, *.msi, *.bat, *.cmd)' { '*.exe', '*.msi', '*.bat', '*.cmd' }
                        'Database (*.sql, *.db, *.sqlite, *.accdb, *.mdb)' { '*.sql', '*.db', '*.sqlite', '*.accdb', '*.mdb' }
                        'Ebooks (*.epub, *.mobi, *.azw, *.azw3, *.pdf)' { '*.epub', '*.mobi', '*.azw', '*.azw3', '*.pdf' }
                        'CAD Files (*.dwg, *.dxf, *.dwt, *.dws)' { '*.dwg', '*.dxf', '*.dwt', '*.dws' }
                        'Font Files (*.ttf, *.otf, *.woff, *.woff2)' { '*.ttf', '*.otf', '*.woff', '*.woff2' }
                        'Configuration Files (*.cfg, *.conf, *.ini, *.json, *.xml, *.yaml, *.yml)' { '*.cfg', '*.conf', '*.ini', '*.json', '*.xml', '*.yaml', '*.yml' }
                        'Log Files (*.log, *.txt)' { '*.log', '*.txt' }
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

    # Restore Tab
    $labelRestorePath = Add-Control -type "Label" -text "Restore path:" -x 10 -y 10 -width 150 -height 20 -parent $restoreTab
    $restorePathBox = Add-Control -type "TextBox" -text "C:\Backup" -x 10 -y 35 -width 450 -height 20 -parent $restoreTab

    $restorePathButton = Add-Control -type "Button" -text "Select Restore Path" -x 470 -y 32 -width 100 -height 25 -parent $restoreTab
    $restorePathButton.Add_Click({
        $folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        if ($folderDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $restorePathBox.Text = $folderDialog.SelectedPath
        }
    })

    $labelRestoreUsers = Add-Control -type "Label" -text "Select profiles to restore:" -x 10 -y 65 -width 250 -height 20 -parent $restoreTab
    $checkboxesRestore = @()
    $restoreUsers = Get-ChildItem -Path $restorePathBox.Text | Where-Object { $_.PSIsContainer }
    $yRestorePosition = 90
    foreach ($restoreUser in $restoreUsers) {
        $checkbox = Add-Control -type "CheckBox" -text $restoreUser.Name -x 10 -y $yRestorePosition -width 250 -height 20 -parent $restoreTab
        $checkboxesRestore += $checkbox
        $yRestorePosition += 30
    }

    $restoreButton = Add-Control -type "Button" -text "Start Restore" -x 10 -y 700 -width 150 -height 30 -parent $restoreTab
    $restoreButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

    $restoreCancelButton = Add-Control -type "Button" -text "Cancel" -x 170 -y 700 -width 150 -height 30 -parent $restoreTab
    $restoreCancelButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left

    $restoreProgressBar = Add-Control -type "ProgressBar" -text "" -x 10 -y 750 -width 650 -height 20 -parent $restoreTab
    $restoreProgressBar.Minimum = 0
    $restoreProgressBar.Maximum = 100
    $restoreProgressBar.Value = 0

    $restoreLogLabel = Add-Control -type "Label" -text "" -x 10 -y 780 -width 650 -height 100 -parent $restoreTab
    $restoreLogLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D

    $restoreCancelRequested = $false

    $restoreCancelButton.Add_Click({
        $restoreCancelRequested = $true
        Write-Host "Restore cancellation requested."
    })

    $restoreButton.Add_Click({
        $selectedRestoreUsers = $checkboxesRestore | Where-Object { $_.Checked }
        if (-not $selectedRestoreUsers) {
            $restoreLogLabel.Text = "Please select at least one profile to restore."
            return
        }

        $restorePath = $restorePathBox.Text
        $restoreTotalFiles = 0
        $restoreCopiedFiles = 0

        foreach ($restoreUser in $selectedRestoreUsers) {
            $sourceRestorePath = Join-Path -Path $restorePath -ChildPath $restoreUser.Text
            $restoreTotalFiles += (Get-ChildItem -Path $sourceRestorePath -Recurse -ErrorAction SilentlyContinue).Count
        }

        if ($restoreTotalFiles -eq 0) {
            $restoreLogLabel.Text = "No files found for the selected profiles."
            return
        }

        $restoreLogFile = Join-Path -Path $restorePath -ChildPath "restore_log.txt"
        Add-Content -Path $restoreLogFile -Value "Restore start: $(Get-Date)"
        $restoreLogLabel.Text = "Restore started..."

        foreach ($restoreUser in $selectedRestoreUsers) {
            if ($restoreCancelRequested) {
                Add-Content -Path $restoreLogFile -Value "Restore cancelled by user: $(Get-Date)"
                $restoreLogLabel.Text = "Restore cancelled."
                return
            }

            $sourceRestorePath = Join-Path -Path $restorePath -ChildPath $restoreUser.Text
            Get-ChildItem -Path $sourceRestorePath -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                if ($restoreCancelRequested) {
                    Add-Content -Path $restoreLogFile -Value "Restore cancelled by user: $(Get-Date)"
                    $restoreLogLabel.Text = "Restore cancelled."
                    return
                }
                try {
                    $destinationRestoreFilePath = $_.FullName.Replace($sourceRestorePath, "C:\Users")
                    $destinationRestoreDir = Split-Path -Path $destinationRestoreFilePath -Parent
                    if (-not (Test-Path -Path $destinationRestoreDir)) {
                        New-Item -ItemType Directory -Path $destinationRestoreDir -Force
                    }
                    Copy-Item -Path $_.FullName -Destination $destinationRestoreFilePath -Force -ErrorAction Stop
                    $restoreCopiedFiles++
                    $restoreProgressValue = [math]::Round((($restoreCopiedFiles / $restoreTotalFiles) * 100), 0)
                    if ($restoreProgressValue -le $restoreProgressBar.Maximum) {
                        $restoreProgressBar.Value = $restoreProgressValue
                    }
                } catch {
                    $restoreLogLabel.Text = "Error copying file: $_.FullName"
                    Add-Content -Path $restoreLogFile -Value "Error copying file: $_.FullName - $_"
                }
            }

            Add-Content -Path $restoreLogFile -Value "Profile $($restoreUser.Text) restored successfully."
        }

        $restoreLogLabel.Text = "Restore completed."
        $restoreProgressBar.Value = 100
        Add-Content -Path $restoreLogFile -Value "Restore end: $(Get-Date)"
    })

    # Show the form
    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

# Call the function to create the GUI
Create-BackupRestoreGUI
