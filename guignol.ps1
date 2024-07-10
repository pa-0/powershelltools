Add-Type -AssemblyName System.Windows.Forms

# Fonction pour ajouter un label avec du texte en UTF-8
function Add-Label {
    param (
        [string]$text,
        [int]$x,
        [int]$y,
        [int]$width = 200,
        [int]$height = 30,
        [float]$fontSize = 12,
        [string]$color = "Black"
    )
    $label = New-Object System.Windows.Forms.Label
    $label.Text = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($text))
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.AutoSize = $false
    $label.Width = $width
    $label.Height = $height
    $label.Font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::FromName($color)
    $form.Controls.Add($label)
    return $label
}

# Créer la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Commandes PowerShell GUI"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Ajouter un panel pour les contrôles avec une barre de défilement
$panel = New-Object System.Windows.Forms.Panel
$panel.AutoScroll = $true
$panel.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($panel)

# Créer des cases à cocher pour différentes commandes (section durcissement)
$labelHarden = Add-Label -text "Batterie :" -x 10 -y 10 -fontSize 14 -color "Blue"
$panel.Controls.Add($labelHarden)

$checkboxBatteryReport = New-Object System.Windows.Forms.CheckBox
$checkboxBatteryReport.Text = "Générer un rapport de batterie"
$checkboxBatteryReport.Location = New-Object System.Drawing.Point(10, 40)
$checkboxBatteryReport.Width = 300
$panel.Controls.Add($checkboxBatteryReport)

$checkboxEnablePUA = New-Object System.Windows.Forms.CheckBox
$checkboxEnablePUA.Text = "Activer les signatures PUA de Defender"
$checkboxEnablePUA.Location = New-Object System.Drawing.Point(10, 70)
$checkboxEnablePUA.Width = 300
$panel.Controls.Add($checkboxEnablePUA)

$checkboxEnableCloudProtection = New-Object System.Windows.Forms.CheckBox
$checkboxEnableCloudProtection.Text = "Activer la protection dans le cloud de Defender"
$checkboxEnableCloudProtection.Location = New-Object System.Drawing.Point(10, 100)
$checkboxEnableCloudProtection.Width = 300
$panel.Controls.Add($checkboxEnableCloudProtection)

$checkboxEnableControlledFolderAccess = New-Object System.Windows.Forms.CheckBox
$checkboxEnableControlledFolderAccess.Text = "Activer l'accès contrôlé aux dossiers"
$checkboxEnableControlledFolderAccess.Location = New-Object System.Drawing.Point(10, 130)
$checkboxEnableControlledFolderAccess.Width = 300
$panel.Controls.Add($checkboxEnableControlledFolderAccess)

$checkboxEnableBitLocker = New-Object System.Windows.Forms.CheckBox
$checkboxEnableBitLocker.Text = "Activer BitLocker"
$checkboxEnableBitLocker.Location = New-Object System.Drawing.Point(10, 160)
$checkboxEnableBitLocker.Width = 300
$panel.Controls.Add($checkboxEnableBitLocker)

# Ajouter un label de section pour l'installation des outils
$labelTools = Add-Label -text "Logiciel a Installer :" -x 10 -y 190 -fontSize 14 -color "Green"
$panel.Controls.Add($labelTools)

$checkboxInstallChrome = New-Object System.Windows.Forms.CheckBox
$checkboxInstallChrome.Text = "Installer Google Chrome"
$checkboxInstallChrome.Location = New-Object System.Drawing.Point(10, 220)
$checkboxInstallChrome.Width = 300
$panel.Controls.Add($checkboxInstallChrome)

$checkboxInstallFirefox = New-Object System.Windows.Forms.CheckBox
$checkboxInstallFirefox.Text = "Installer Firefox"
$checkboxInstallFirefox.Location = New-Object System.Drawing.Point(10, 250)
$checkboxInstallFirefox.Width = 300
$panel.Controls.Add($checkboxInstallFirefox)

$checkboxInstallCDBurnerXP = New-Object System.Windows.Forms.CheckBox
$checkboxInstallCDBurnerXP.Text = "Installer CDBurnerXP"
$checkboxInstallCDBurnerXP.Location = New-Object System.Drawing.Point(10, 280)
$checkboxInstallCDBurnerXP.Width = 300
$panel.Controls.Add($checkboxInstallCDBurnerXP)

$checkboxInstallLibreOffice = New-Object System.Windows.Forms.CheckBox
$checkboxInstallLibreOffice.Text = "Installer LibreOffice"
$checkboxInstallLibreOffice.Location = New-Object System.Drawing.Point(10, 310)
$checkboxInstallLibreOffice.Width = 300
$panel.Controls.Add($checkboxInstallLibreOffice)

$checkboxInstall7Zip = New-Object System.Windows.Forms.CheckBox
$checkboxInstall7Zip.Text = "Installer 7-Zip"
$checkboxInstall7Zip.Location = New-Object System.Drawing.Point(10, 340)
$checkboxInstall7Zip.Width = 300
$panel.Controls.Add($checkboxInstall7Zip)

$checkboxInstallAnyDesk = New-Object System.Windows.Forms.CheckBox
$checkboxInstallAnyDesk.Text = "Installer AnyDesk"
$checkboxInstallAnyDesk.Location = New-Object System.Drawing.Point(10, 370)
$checkboxInstallAnyDesk.Width = 300
$panel.Controls.Add($checkboxInstallAnyDesk)

# Ajouter un label de section pour les nouvelles options de durcissement
$labelHarden2 = Add-Label -text "Optionnel :" -x 10 -y 400 -fontSize 14 -color "Blue"
$panel.Controls.Add($labelHarden2)

$checkboxDisableDCOM = New-Object System.Windows.Forms.CheckBox
$checkboxDisableDCOM.Text = "Désactiver DCOM"
$checkboxDisableDCOM.Location = New-Object System.Drawing.Point(10, 430)
$checkboxDisableDCOM.Width = 300
$panel.Controls.Add($checkboxDisableDCOM)

$checkboxDisableSMBv1 = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSMBv1.Text = "Désactiver SMBv1"
$checkboxDisableSMBv1.Location = New-Object System.Drawing.Point(10, 460)
$checkboxDisableSMBv1.Width = 300
$panel.Controls.Add($checkboxDisableSMBv1)

$checkboxEnableFirewall = New-Object System.Windows.Forms.CheckBox
$checkboxEnableFirewall.Text = "Activer le pare-feu Windows"
$checkboxEnableFirewall.Location = New-Object System.Drawing.Point(10, 490)
$checkboxEnableFirewall.Width = 300
$panel.Controls.Add($checkboxEnableFirewall)

# Ajouter un label de section pour les options d'économie d'énergie
$labelPowerOptions = Add-Label -text "Options d'économie d'énergie :" -x 10 -y 520 -fontSize 14 -color "Green"
$panel.Controls.Add($labelPowerOptions)

$checkboxDisableScreenSaver = New-Object System.Windows.Forms.CheckBox
$checkboxDisableScreenSaver.Text = "Désactiver la mise en veille de l'écran"
$checkboxDisableScreenSaver.Location = New-Object System.Drawing.Point(10, 550)
$checkboxDisableScreenSaver.Width = 300
$panel.Controls.Add($checkboxDisableScreenSaver)

$checkboxDisableSleep = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSleep.Text = "Désactiver la mise en veille du PC"
$checkboxDisableSleep.Location = New-Object System.Drawing.Point(10, 580)
$checkboxDisableSleep.Width = 300
$panel.Controls.Add($checkboxDisableSleep)

# Ajouter un label de section pour les options de maintenance
$labelMaintenance = Add-Label -text "Options de maintenance :" -x 10 -y 610 -fontSize 14 -color "Purple"
$panel.Controls.Add($labelMaintenance)

$checkboxDeleteUpdateFolder = New-Object System.Windows.Forms.CheckBox
$checkboxDeleteUpdateFolder.Text = "Effacer le dossier Windows Update"
$checkboxDeleteUpdateFolder.Location = New-Object System.Drawing.Point(10, 640)
$checkboxDeleteUpdateFolder.Width = 300
$panel.Controls.Add($checkboxDeleteUpdateFolder)

$checkboxDeletePIN = New-Object System.Windows.Forms.CheckBox
$checkboxDeletePIN.Text = "Effacer le PIN Windows"
$checkboxDeletePIN.Location = New-Object System.Drawing.Point(10, 670)
$checkboxDeletePIN.Width = 300
$panel.Controls.Add($checkboxDeletePIN)

# Ajouter des cases à cocher pour les nouvelles options
$checkboxDisableRemoteDesktop = New-Object System.Windows.Forms.CheckBox
$checkboxDisableRemoteDesktop.Text = "Désactiver le Bureau à distance"
$checkboxDisableRemoteDesktop.Location = New-Object System.Drawing.Point(10, 700)
$checkboxDisableRemoteDesktop.Width = 300
$panel.Controls.Add($checkboxDisableRemoteDesktop)

$checkboxEnableHyperV = New-Object System.Windows.Forms.CheckBox
$checkboxEnableHyperV.Text = "Activer Hyper-V"
$checkboxEnableHyperV.Location = New-Object System.Drawing.Point(10, 730)
$checkboxEnableHyperV.Width = 300
$panel.Controls.Add($checkboxEnableHyperV)

$checkboxClearEventLogs = New-Object System.Windows.Forms.CheckBox
$checkboxClearEventLogs.Text = "Effacer les journaux d'événements"
$checkboxClearEventLogs.Location = New-Object System.Drawing.Point(10, 760)
$checkboxClearEventLogs.Width = 300
$panel.Controls.Add($checkboxClearEventLogs)

$checkboxEnableWSL = New-Object System.Windows.Forms.CheckBox
$checkboxEnableWSL.Text = "Activer WSL"
$checkboxEnableWSL.Location = New-Object System.Drawing.Point(10, 790)
$checkboxEnableWSL.Width = 300
$panel.Controls.Add($checkboxEnableWSL)

$checkboxResetTCPIP = New-Object System.Windows.Forms.CheckBox
$checkboxResetTCPIP.Text = "Réinitialiser TCP/IP"
$checkboxResetTCPIP.Location = New-Object System.Drawing.Point(10, 820)
$checkboxResetTCPIP.Width = 300
$panel.Controls.Add($checkboxResetTCPIP)

# Ajouter des cases à cocher pour 10 nouvelles options
$labelNewOptions = Add-Label -text "Autre Options :" -x 10 -y 850 -fontSize 14 -color "Orange"
$panel.Controls.Add($labelNewOptions)

$checkboxDisableWindowsSearch = New-Object System.Windows.Forms.CheckBox
$checkboxDisableWindowsSearch.Text = "Désactiver Windows Search"
$checkboxDisableWindowsSearch.Location = New-Object System.Drawing.Point(10, 880)
$checkboxDisableWindowsSearch.Width = 300
$panel.Controls.Add($checkboxDisableWindowsSearch)

$checkboxDisableSuperfetch = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSuperfetch.Text = "Désactiver Superfetch"
$checkboxDisableSuperfetch.Location = New-Object System.Drawing.Point(10, 910)
$checkboxDisableSuperfetch.Width = 300
$panel.Controls.Add($checkboxDisableSuperfetch)

$checkboxDisableWindowsDefender = New-Object System.Windows.Forms.CheckBox
$checkboxDisableWindowsDefender.Text = "Désactiver Windows Defender"
$checkboxDisableWindowsDefender.Location = New-Object System.Drawing.Point(10, 940)
$checkboxDisableWindowsDefender.Width = 300
$panel.Controls.Add($checkboxDisableWindowsDefender)

$checkboxEnableRDP = New-Object System.Windows.Forms.CheckBox
$checkboxEnableRDP.Text = "Activer le Bureau à distance"
$checkboxEnableRDP.Location = New-Object System.Drawing.Point(10, 970)
$checkboxEnableRDP.Width = 300
$panel.Controls.Add($checkboxEnableRDP)

$checkboxEnableSystemRestore = New-Object System.Windows.Forms.CheckBox
$checkboxEnableSystemRestore.Text = "Activer la restauration du système"
$checkboxEnableSystemRestore.Location = New-Object System.Drawing.Point(10, 1000)
$checkboxEnableSystemRestore.Width = 300
$panel.Controls.Add($checkboxEnableSystemRestore)

$checkboxDisableSystemRestore = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSystemRestore.Text = "Désactiver la restauration du système"
$checkboxDisableSystemRestore.Location = New-Object System.Drawing.Point(10, 1030)
$checkboxDisableSystemRestore.Width = 300
$panel.Controls.Add($checkboxDisableSystemRestore)

$checkboxDisableHibernation = New-Object System.Windows.Forms.CheckBox
$checkboxDisableHibernation.Text = "Désactiver l'hibernation"
$checkboxDisableHibernation.Location = New-Object System.Drawing.Point(10, 1060)
$checkboxDisableHibernation.Width = 300
$panel.Controls.Add($checkboxDisableHibernation)

$checkboxEnableHibernation = New-Object System.Windows.Forms.CheckBox
$checkboxEnableHibernation.Text = "Activer l'hibernation"
$checkboxEnableHibernation.Location = New-Object System.Drawing.Point(10, 1090)
$checkboxEnableHibernation.Width = 300
$panel.Controls.Add($checkboxEnableHibernation)

$checkboxDisableFastStartup = New-Object System.Windows.Forms.CheckBox
$checkboxDisableFastStartup.Text = "Désactiver le démarrage rapide"
$checkboxDisableFastStartup.Location = New-Object System.Drawing.Point(10, 1120)
$checkboxDisableFastStartup.Width = 300
$panel.Controls.Add($checkboxDisableFastStartup)

$checkboxEnableFastStartup = New-Object System.Windows.Forms.CheckBox
$checkboxEnableFastStartup.Text = "Activer le démarrage rapide"
$checkboxEnableFastStartup.Location = New-Object System.Drawing.Point(10, 1150)
$checkboxEnableFastStartup.Width = 300
$panel.Controls.Add($checkboxEnableFastStartup)

# Ajouter une zone de texte pour afficher les logs
$logBox = New-Object System.Windows.Forms.TextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Location = New-Object System.Drawing.Point(320, 40)
$logBox.Size = New-Object System.Drawing.Size(450, 400)
$logBox.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Regular)
$logBox.ReadOnly = $true
$panel.Controls.Add($logBox)

# Fonction pour ajouter du texte aux logs
function Add-Log {
    param (
        [string]$message
    )
    $logBox.AppendText("$message`r`n")
}

# Ajouter des informations système (BIOS, hostname, IPs, disques, partages, etc.)
$hostname = [System.Net.Dns]::GetHostName()
$bios = (Get-WmiObject -Class Win32_BIOS).BIOSVersion -join ", "
$uefi = (Get-WmiObject -Class Win32_BootConfiguration).BootType -eq "EFI"
$os = (Get-WmiObject -Class Win32_OperatingSystem).Caption
$networkInfo = Get-NetIPAddress | Select-Object InterfaceAlias, IPAddress
$disks = Get-WmiObject -Class Win32_DiskDrive | Select-Object Model, Size, MediaType
$logicalDisks = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 } | Select-Object DeviceID, VolumeName
$shares = Get-WmiObject -Class Win32_Share | Select-Object Name, Path
$netDrives = Get-WmiObject -Class Win32_NetworkConnection | Select-Object LocalName, RemoteName
$domain = (Get-WmiObject -Class Win32_ComputerSystem).Domain

# Créer un texte formaté pour afficher les informations système
$infoText = @"
Hostname : $hostname
BIOS : $bios
UEFI : $uefi
OS : $os
Domain : $domain
"@

# Ajouter les informations réseau
$networkInfo | ForEach-Object {
    $infoText += "Interface : $($_.InterfaceAlias) - IP : $($_.IPAddress)`n"
}

# Ajouter les informations des disques physiques
$disks | ForEach-Object {
    $infoText += "Disque : $($_.Model) - Taille : $([math]::round($_.Size / 1GB, 2)) GB - Type : $($_.MediaType)`n"
}

# Ajouter les informations des disques logiques
$logicalDisks | ForEach-Object {
    $infoText += "Disque logique : $($_.DeviceID) - Nom : $($_.VolumeName)`n"
}

# Ajouter les informations des partages réseau
$shares | ForEach-Object {
    $infoText += "Partage réseau : $($_.Name) - Chemin : \\$($_.Path)`n"
}

# Ajouter les informations des disques réseau montés
$netDrives | ForEach-Object {
    $infoText += "Disque réseau : $($_.LocalName) - Chemin : \\$($_.RemoteName)`n"
}

# Afficher les informations système dans la zone de log
Add-Log "Informations système :"
Add-Log $infoText

# Ajouter un bouton "Appliquer"
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = "Appliquer"
$applyButton.Location = New-Object System.Drawing.Point(320, 880)
$applyButton.Size = New-Object System.Drawing.Size(100, 30)
$applyButton.Add_Click({
    if ($checkboxBatteryReport.Checked) {
        Add-Log "Génération du rapport de batterie..."
        try {
            powercfg /batteryreport /output "C:\battery-report.html"
            Start-Process "C:\battery-report.html"
            Add-Log "Rapport de batterie généré."
        } catch {
            Add-Log "Erreur lors de la génération du rapport de batterie : $_"
        }
    }
    if ($checkboxEnablePUA.Checked) {
        Add-Log "Activation des signatures PUA de Defender..."
        try {
            Set-MpPreference -PUAProtection Enabled
            Add-Log "Signatures PUA activées."
        } catch {
            Add-Log "Erreur lors de l'activation des signatures PUA de Defender : $_"
        }
    }
    if ($checkboxEnableCloudProtection.Checked) {
        Add-Log "Activation de la protection dans le cloud de Defender..."
        try {
            Set-MpPreference -MAPSReporting Advanced
            Add-Log "Protection cloud activée."
        } catch {
            Add-Log "Erreur lors de l'activation de la protection dans le cloud de Defender : $_"
        }
    }
    if ($checkboxEnableControlledFolderAccess.Checked) {
        Add-Log "Activation de l'accès contrôlé aux dossiers..."
        try {
            Set-MpPreference -EnableControlledFolderAccess Enabled
            Add-Log "Accès contrôlé aux dossiers activé."
        } catch {
            Add-Log "Erreur lors de l'activation de l'accès contrôlé aux dossiers : $_"
        }
    }
    if ($checkboxEnableBitLocker.Checked) {
        Add-Log "Activation de BitLocker..."
        try {
            Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256
            Add-Log "BitLocker activé."
        } catch {
            Add-Log "Erreur lors de l'activation de BitLocker : $_"
        }
    }
    if ($checkboxInstallChrome.Checked) {
        Add-Log "Installation de Google Chrome..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi /qn" -Wait
            Add-Log "Google Chrome installé."
        } catch {
            Add-Log "Erreur lors de l'installation de Google Chrome : $_"
        }
    }
    if ($checkboxInstallFirefox.Checked) {
        Add-Log "Installation de Mozilla Firefox..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US /qn" -Wait
            Add-Log "Mozilla Firefox installé."
        } catch {
            Add-Log "Erreur lors de l'installation de Mozilla Firefox : $_"
        }
    }
    if ($checkboxInstallCDBurnerXP.Checked) {
        Add-Log "Installation de CDBurnerXP..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.cdburnerxp.se/setup_x64.exe /qn" -Wait
            Add-Log "CDBurnerXP installé."
        } catch {
            Add-Log "Erreur lors de l'installation de CDBurnerXP : $_"
        }
    }
    if ($checkboxInstallLibreOffice.Checked) {
        Add-Log "Installation de LibreOffice..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.documentfoundation.org/libreoffice/stable/7.3.2/win/x86_64/LibreOffice_7.3.2_Win_x64.msi /qn" -Wait
            Add-Log "LibreOffice installé."
        } catch {
            Add-Log "Erreur lors de l'installation de LibreOffice : $_"
        }
    }
    if ($checkboxInstall7Zip.Checked) {
        Add-Log "Installation de 7-Zip..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://www.7-zip.org/a/7z1900-x64.msi /qn" -Wait
            Add-Log "7-Zip installé."
        } catch {
            Add-Log "Erreur lors de l'installation de 7-Zip : $_"
        }
    }
    if ($checkboxInstallAnyDesk.Checked) {
        Add-Log "Installation d'AnyDesk..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.anydesk.com/AnyDesk.msi /qn" -Wait
            Add-Log "AnyDesk installé."
        } catch {
            Add-Log "Erreur lors de l'installation d'AnyDesk : $_"
        }
    }
    if ($checkboxDisableDCOM.Checked) {
        Add-Log "Désactivation de DCOM..."
        try {
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\Ole" -Name "EnableDCOM" -Value "N"
            Add-Log "DCOM désactivé."
        } catch {
            Add-Log "Erreur lors de la désactivation de DCOM : $_"
        }
    }
    if ($checkboxDisableSMBv1.Checked) {
        Add-Log "Désactivation de SMBv1..."
        try {
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
            Add-Log "SMBv1 désactivé."
        } catch {
            Add-Log "Erreur lors de la désactivation de SMBv1 : $_"
        }
    }
    if ($checkboxEnableFirewall.Checked) {
        Add-Log "Activation du pare-feu Windows..."
        try {
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
            Add-Log "Pare-feu Windows activé."
        } catch {
            Add-Log "Erreur lors de l'activation du pare-feu Windows : $_"
        }
    }
    if ($checkboxDisableScreenSaver.Checked) {
        Add-Log "Désactivation de la mise en veille de l'écran..."
        try {
            powercfg -change monitor-timeout-ac 0
            powercfg -change monitor-timeout-dc 0
            Add-Log "Mise en veille de l'écran désactivée."
        } catch {
            Add-Log "Erreur lors de la désactivation de la mise en veille de l'écran : $_"
        }
    }
    if ($checkboxDisableSleep.Checked) {
        Add-Log "Désactivation de la mise en veille du PC..."
        try {
            powercfg -change standby-timeout-ac 0
            powercfg -change standby-timeout-dc 0
            Add-Log "Mise en veille du PC désactivée."
        } catch {
            Add-Log "Erreur lors de la désactivation de la mise en veille du PC : $_"
        }
    }
    if ($checkboxDeleteUpdateFolder.Checked) {
        Add-Log "Effacement du dossier Windows Update..."
        try {
            Stop-Service wuauserv -Force
            Remove-Item "C:\Windows\SoftwareDistribution" -Recurse -Force
            Start-Service wuauserv
            Add-Log "Dossier Windows Update effacé."
        } catch {
            Add-Log "Erreur lors de l'effacement du dossier Windows Update : $_"
        }
    }
    if ($checkboxDeletePIN.Checked) {
        Add-Log "Effacement du PIN Windows..."
        try {
            takeown /F "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc" /R
            attrib -h -r -s /s /d "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"
            rmdir /s /q "C:\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"
            Add-Log "PIN Windows effacé."
        } catch {
            Add-Log "Erreur lors de l'effacement du PIN Windows : $_"
        }
    }
    if ($checkboxDisableRemoteDesktop.Checked) {
        Add-Log "Désactivation du Bureau à distance..."
        try {
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1
            Add-Log "Bureau à distance désactivé."
        } catch {
            Add-Log "Erreur lors de la désactivation du Bureau à distance : $_"
        }
    }
    if ($checkboxEnableHyperV.Checked) {
        Add-Log "Activation de Hyper-V..."
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
            Add-Log "Hyper-V activé."
        } catch {
            Add-Log "Erreur lors de l'activation de Hyper-V : $_"
        }
    }
    if ($checkboxClearEventLogs.Checked) {
        Add-Log "Effacement des journaux d'événements..."
        try {
            wevtutil el | Foreach-Object {wevtutil cl "$_"}
            Add-Log "Journaux d'événements effacés."
        } catch {
            Add-Log "Erreur lors de l'effacement des journaux d'événements : $_"
        }
    }
    if ($checkboxEnableWSL.Checked) {
        Add-Log "Activation du sous-système Windows pour Linux (WSL)..."
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
            Add-Log "WSL activé."
        } catch {
            Add-Log "Erreur lors de l'activation du sous-système Windows pour Linux (WSL) : $_"
        }
    }
    if ($checkboxResetTCPIP.Checked) {
        Add-Log "Réinitialisation des paramètres TCP/IP..."
        try {
            netsh int ip reset
            Add-Log "Paramètres TCP/IP réinitialisés."
        } catch {
            Add-Log "Erreur lors de la réinitialisation des paramètres TCP/IP : $_"
        }
    }
    if ($checkboxDisableWindowsSearch.Checked) {
        Add-Log "Désactivation de Windows Search..."
        try {
            Stop-Service WSearch
            Set-Service WSearch -StartupType Disabled
            Add-Log "Windows Search désactivé."
        } catch {
            Add-Log "Erreur lors de la désactivation de Windows Search : $_"
        }
    }
    if ($checkboxDisableSuperfetch.Checked) {
        Add-Log "Désactivation de Superfetch..."
        try {
            Stop-Service SysMain
            Set-Service SysMain -StartupType Disabled
            Add-Log "Superfetch désactivé."
        } catch {
            Add-Log "Erreur lors de la désactivation de Superfetch : $_"
        }
    }
    if ($checkboxDisableWindowsDefender.Checked) {
        Add-Log "Désactivation de Windows Defender..."
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true
            Add-Log "Windows Defender désactivé."
        } catch {
            Add-Log "Erreur lors de la désactivation de Windows Defender : $_"
        }
    }
    if ($checkboxEnableRDP.Checked) {
        Add-Log "Activation du Bureau à distance..."
        try {
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
            Add-Log "Bureau à distance activé."
        } catch {
            Add-Log "Erreur lors de l'activation du Bureau à distance : $_"
        }
    }
    if ($checkboxEnableSystemRestore.Checked) {
        Add-Log "Activation de la restauration du système..."
        try {
            Enable-ComputerRestore -Drive "C:\"
            Add-Log "Restauration du système activée."
        } catch {
            Add-Log "Erreur lors de l'activation de la restauration du système : $_"
        }
    }
    if ($checkboxDisableSystemRestore.Checked) {
        Add-Log "Désactivation de la restauration du système..."
        try {
            Disable-ComputerRestore -Drive "C:\"
            Add-Log "Restauration du système désactivée."
        } catch {
            Add-Log "Erreur lors de la désactivation de la restauration du système : $_"
        }
    }
    if ($checkboxDisableHibernation.Checked) {
        Add-Log "Désactivation de l'hibernation..."
        try {
            powercfg -h off
            Add-Log "Hibernation désactivée."
        } catch {
            Add-Log "Erreur lors de la désactivation de l'hibernation : $_"
        }
    }
    if ($checkboxEnableHibernation.Checked) {
        Add-Log "Activation de l'hibernation..."
        try {
            powercfg -h on
            Add-Log "Hibernation activée."
        } catch {
            Add-Log "Erreur lors de l'activation de l'hibernation : $_"
        }
    }
    if ($checkboxDisableFastStartup.Checked) {
        Add-Log "Désactivation du démarrage rapide..."
        try {
            powercfg -h off
            Add-Log "Démarrage rapide désactivé."
        } catch {
            Add-Log "Erreur lors de la désactivation du démarrage rapide : $_"
        }
    }
    if ($checkboxEnableFastStartup.Checked) {
        Add-Log "Activation du démarrage rapide..."
        try {
            powercfg -h on
            Add-Log "Démarrage rapide activé."
        } catch {
            Add-Log "Erreur lors de l'activation du démarrage rapide : $_"
        }
    }
})

$panel.Controls.Add($applyButton)

# Ajouter des info-bulles
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.SetToolTip($checkboxBatteryReport, "Génère un rapport détaillé de la batterie")
$toolTip.SetToolTip($checkboxEnablePUA, "Active les signatures pour les applications potentiellement indésirables (PUA)")
$toolTip.SetToolTip($checkboxEnableCloudProtection, "Active la protection cloud pour Microsoft Defender")
$toolTip.SetToolTip($checkboxEnableControlledFolderAccess, "Active l'accès contrôlé aux dossiers pour protéger contre les ransomwares")
$toolTip.SetToolTip($checkboxEnableBitLocker, "Active le chiffrement BitLocker pour protéger les données")
$toolTip.SetToolTip($checkboxInstallChrome, "Installe le navigateur Google Chrome")
$toolTip.SetToolTip($checkboxInstallFirefox, "Installe le navigateur Mozilla Firefox")
$toolTip.SetToolTip($checkboxInstallCDBurnerXP, "Installe le logiciel de gravure CDBurnerXP")
$toolTip.SetToolTip($checkboxInstallLibreOffice, "Installe la suite bureautique LibreOffice")
$toolTip.SetToolTip($checkboxInstall7Zip, "Installe l'utilitaire de compression 7-Zip")
$toolTip.SetToolTip($checkboxInstallAnyDesk, "Installe le logiciel de télémaintenance AnyDesk")
$toolTip.SetToolTip($checkboxDisableDCOM, "Désactive le composant Distributed Component Object Model (DCOM)")
$toolTip.SetToolTip($checkboxDisableSMBv1, "Désactive le protocole Server Message Block version 1 (SMBv1)")
$toolTip.SetToolTip($checkboxEnableFirewall, "Active le pare-feu Windows pour les profils de domaine, public et privé")
$toolTip.SetToolTip($checkboxDisableScreenSaver, "Désactive la mise en veille de l'écran")
$toolTip.SetToolTip($checkboxDisableSleep, "Désactive la mise en veille du PC")
$toolTip.SetToolTip($checkboxDeleteUpdateFolder, "Efface le dossier de distribution de Windows Update")
$toolTip.SetToolTip($checkboxDeletePIN, "Efface le PIN Windows actuel")
$toolTip.SetToolTip($checkboxDisableRemoteDesktop, "Désactive le Bureau à distance pour empêcher les connexions distantes")
$toolTip.SetToolTip($checkboxEnableHyperV, "Active Hyper-V pour la virtualisation")
$toolTip.SetToolTip($checkboxClearEventLogs, "Efface tous les journaux d'événements Windows")
$toolTip.SetToolTip($checkboxEnableWSL, "Active le sous-système Windows pour Linux (WSL)")
$toolTip.SetToolTip($checkboxResetTCPIP, "Réinitialise les paramètres TCP/IP")
$toolTip.SetToolTip($checkboxDisableWindowsSearch, "Désactive Windows Search pour améliorer les performances")
$toolTip.SetToolTip($checkboxDisableSuperfetch, "Désactive Superfetch pour améliorer les performances")
$toolTip.SetToolTip($checkboxDisableWindowsDefender, "Désactive Windows Defender pour les tests")
$toolTip.SetToolTip($checkboxEnableRDP, "Active le Bureau à distance")
$toolTip.SetToolTip($checkboxEnableSystemRestore, "Active la restauration du système")
$toolTip.SetToolTip($checkboxDisableSystemRestore, "Désactive la restauration du système")
$toolTip.SetToolTip($checkboxDisableHibernation, "Désactive l'hibernation pour économiser de l'espace disque")
$toolTip.SetToolTip($checkboxEnableHibernation, "Active l'hibernation")
$toolTip.SetToolTip($checkboxDisableFastStartup, "Désactive le démarrage rapide")
$toolTip.SetToolTip($checkboxEnableFastStartup, "Active le démarrage rapide")

# Afficher la fenêtre
$form.ShowDialog()
