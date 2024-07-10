Add-Type -AssemblyName System.Windows.Forms

# Créer le formulaire
$form = New-Object System.Windows.Forms.Form
$form.Text = "Sélection de la sauvegarde"
$form.Size = New-Object System.Drawing.Size(400, 600)
$form.StartPosition = "CenterScreen"

# Ajouter une étiquette pour le chemin de sauvegarde
$label = New-Object System.Windows.Forms.Label
$label.Text = "Chemin de sauvegarde :"
$label.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($label)

# Ajouter une boîte de texte pour entrer le chemin de sauvegarde
$backupPathBox = New-Object System.Windows.Forms.TextBox
$backupPathBox.Size = New-Object System.Drawing.Size(250, 20)
$backupPathBox.Location = New-Object System.Drawing.Point(10, 30)
$backupPathBox.Text = "C:\Backup"
$form.Controls.Add($backupPathBox)

# Ajouter des checkboxes pour les types de fichiers et autres options de sauvegarde
$checkboxes = @()
$fileTypes = @("Documents", "Music", "Videos", "Images", "Programs", "Other", "Imprimante Drivers", "Windows Drivers", "Profils Utilisateurs", "Crypto Wallets")
for ($i = 0; $i -lt $fileTypes.Length; $i++) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $fileTypes[$i]
    $checkbox.Location = New-Object System.Drawing.Point(10, 60 + ($i * 30))
    $form.Controls.Add($checkbox)
    $checkboxes += $checkbox
}

# Ajouter une barre de progression
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Minimum = 0
$progressBar.Maximum = 100
$progressBar.Value = 0
$progressBar.Size = New-Object System.Drawing.Size(350, 20)
$progressBar.Location = New-Object System.Drawing.Point(10, 450)
$form.Controls.Add($progressBar)

# Ajouter une étiquette pour afficher les erreurs
$errorLabel = New-Object System.Windows.Forms.Label
$errorLabel.Size = New-Object System.Drawing.Size(350, 50)
$errorLabel.Location = New-Object System.Drawing.Point(10, 480)
$form.Controls.Add($errorLabel)

# Ajouter un bouton pour lancer la sauvegarde
$okButton = New-Object System.Windows.Forms.Button
$okButton.Text = "Lancer la sauvegarde"
$okButton.Location = New-Object System.Drawing.Point(10, 540)
$form.Controls.Add($okButton)

# Ajouter un bouton pour annuler la sauvegarde
$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Annuler"
$cancelButton.Location = New-Object System.Drawing.Point(120, 540)
$form.Controls.Add($cancelButton)

# Variable pour gérer l'annulation
$cancelRequested = $false

$cancelButton.Add_Click({
    $cancelRequested = $true
    Write-Host "Annulation de la sauvegarde demandée."
})

$okButton.Add_Click({
    $backupPath = $backupPathBox.Text
    if (-not (Test-Path -Path $backupPath)) {
        try {
            New-Item -ItemType Directory -Path $backupPath -ErrorAction Stop
        } catch {
            $errorLabel.Text = "Erreur de création du répertoire de sauvegarde : $_"
            return
        }
    }

    $fileExtensions = @{
        "Documents" = @("*.doc", "*.docx", "*.pdf", "*.txt", "*.xls", "*.xlsx", "*.ppt", "*.pptx")
        "Music" = @("*.mp3", "*.wav", "*.aac", "*.flac", "*.m4a")
        "Videos" = @("*.mp4", "*.avi", "*.mkv", "*.mov", "*.wmv")
        "Images" = @("*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.tiff")
        "Programs" = @("*.exe", "*.msi", "*.bat", "*.cmd", "*.ps1")
        "Other" = @("*.*")
        "Crypto Wallets" = @("*.wallet", "*.crypto", "*.json")
    }

    $totalFiles = 0
    $copiedFiles = 0

    # Compter le nombre total de fichiers à copier
    foreach ($checkbox in $checkboxes) {
        if ($checkbox.Checked) {
            $type = $checkbox.Text
            if ($type -eq "Imprimante Drivers" -or $type -eq "Windows Drivers" -or $type -eq "Profils Utilisateurs") {
                continue
            }
            foreach ($extension in $fileExtensions[$type]) {
                $totalFiles += (Get-ChildItem -Path "C:\Users\*" -Include $extension -Recurse -ErrorAction SilentlyContinue).Count
            }
        }
    }

    if ($totalFiles -eq 0 -and -not ($checkboxes | Where-Object { $_.Checked -and $_.Text -eq "Imprimante Drivers" -or $_.Text -eq "Windows Drivers" -or $_.Text -eq "Profils Utilisateurs" })) {
        $errorLabel.Text = "Aucun fichier trouvé pour les types sélectionnés."
        return
    }

    # Journalisation des opérations
    $logFile = Join-Path -Path $backupPath -ChildPath "backup_log.txt"
    Add-Content -Path $logFile -Value "Début de la sauvegarde : $(Get-Date)"

    # Sauvegarder les fichiers et mettre à jour la barre de progression
    foreach ($checkbox in $checkboxes) {
        if ($checkbox.Checked) {
            $type = $checkbox.Text
            if ($type -eq "Imprimante Drivers") {
                # Sauvegarder les drivers d'imprimantes
                $printerDriversBackupPath = Join-Path -Path $backupPath -ChildPath "PrinterDrivers"
                if (-not (Test-Path -Path $printerDriversBackupPath)) {
                    New-Item -ItemType Directory -Path $printerDriversBackupPath -Force
                }
                Start-Process -FilePath "printui.exe" -ArgumentList "/e", "/n", "/o", "/x", "/m", "*", "/path", $printerDriversBackupPath -NoNewWindow -Wait
                Add-Content -Path $logFile -Value "Sauvegarde des drivers d'imprimantes terminée."
            } elseif ($type -eq "Windows Drivers") {
                # Sauvegarder les drivers Windows
                $windowsDriversBackupPath = Join-Path -Path $backupPath -ChildPath "WindowsDrivers"
                Export-WindowsDriver -Online -Destination $windowsDriversBackupPath
                Add-Content -Path $logFile -Value "Sauvegarde des drivers Windows terminée."
            } elseif ($type -eq "Profils Utilisateurs") {
                # Sauvegarder les profils utilisateurs
                $users = Get-ChildItem -Path "C:\Users" -Directory
                foreach ($user in $users) {
                    $destinationPath = Join-Path -Path $backupPath -ChildPath "Users\$($user.Name)"
                    Copy-Item -Path $user.FullName -Destination $destinationPath -Recurse -Force -ErrorAction SilentlyContinue
                }
                Add-Content -Path $logFile -Value "Sauvegarde des profils utilisateurs terminée."
            } else {
                # Sauvegarder les fichiers sélectionnés
                foreach ($extension in $fileExtensions[$type]) {
                    $files = Get-ChildItem -Path "C:\Users\*" -Include $extension -Recurse -ErrorAction SilentlyContinue
                    foreach ($file in $files) {
                        if ($cancelRequested) {
                            Add-Content -Path $logFile -Value "Sauvegarde annulée par l'utilisateur : $(Get-Date)"
                            [System.Windows.Forms.MessageBox]::Show("Sauvegarde annulée.")
                            return
                        }

                        try {
                            $destinationPath = Join-Path -Path $backupPath -ChildPath $file.FullName.Substring(3)
                            $destinationDir = Split-Path -Path $destinationPath -Parent
                            if (-not (Test-Path -Path $destinationDir)) {
                                New-Item -ItemType Directory -Path $destinationDir -Force
                            }
                            Copy-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
                            $copiedFiles++
                            $progressBar.Value = [math]::Round(($copiedFiles / $totalFiles) * 100)
                            Add-Content -Path $logFile -Value "Fichier copié : $($file.FullName) vers $destinationPath"
                        } catch {
                            $errorLabel.Text += "Erreur de copie du fichier $($file.FullName) : $_`n"
                            Add-Content -Path $logFile -Value "Erreur de copie du fichier $($file.FullName) : $_"
                        }
                    }
                }
            }
        }
    }

    [System.Windows.Forms.MessageBox]::Show("Sauvegarde terminée.")
    $progressBar.Value = 100
    Add-Content -Path $logFile -Value "Fin de la sauvegarde : $(Get-Date)"
})

# Afficher le formulaire
$form.Topmost = $true
$form.Add_Shown({$form.Activate()})
[void]$form.ShowDialog()
