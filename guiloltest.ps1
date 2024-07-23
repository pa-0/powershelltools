Add-Type -AssemblyName System.Windows.Forms
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8


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
    $label.Text = $text
    $label.Location = New-Object System.Drawing.Point($x, $y)
    $label.AutoSize = $false
    $label.Width = $width
    $label.Height = $height
    $label.Font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold)
    $label.ForeColor = [System.Drawing.Color]::FromName($color)
    $form.Controls.Add($label)
    return $label
}

function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value
    )
    Invoke-Command -ScriptBlock {
        param ($Path, $Name, $Value)
        Set-ItemProperty -Path $Path -Name $Name -Value $Value -Force
    } -ArgumentList $Path, $Name, $Value
}

function Add-StatusCircle {
    param (
        [int]$x,
        [int]$y,
        [string]$color = "Red"
    )
    $circle = New-Object System.Windows.Forms.PictureBox
    $circle.Size = New-Object System.Drawing.Size(20, 20)
    $circle.Location = New-Object System.Drawing.Point($x, $y)
    $circle.BackColor = [System.Drawing.Color]::FromName($color)
    $circle.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $circle
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Commandes PowerShell GUI"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

$panel = New-Object System.Windows.Forms.Panel
$panel.AutoScroll = $true
$panel.Dock = [System.Windows.Forms.DockStyle]::Fill
$form.Controls.Add($panel)

$labelHarden = Add-Label -text "Batterie :" -x 10 -y 10 -fontSize 14 -color "Blue"
$panel.Controls.Add($labelHarden)

$checkboxBatteryReport = New-Object System.Windows.Forms.CheckBox
$checkboxBatteryReport.Text = "Générer un rapport de batterie"
$checkboxBatteryReport.Location = New-Object System.Drawing.Point(10, 40)
$checkboxBatteryReport.Width = 300
$panel.Controls.Add($checkboxBatteryReport)

$statusBatteryReport = Add-StatusCircle -x 320 -y 40 -color "Red"
$panel.Controls.Add($statusBatteryReport)

$checkboxEnablePUA = New-Object System.Windows.Forms.CheckBox
$checkboxEnablePUA.Text = "Activer les signatures PUA de Defender"
$checkboxEnablePUA.Location = New-Object System.Drawing.Point(10, 70)
$checkboxEnablePUA.Width = 300
$panel.Controls.Add($checkboxEnablePUA)

$statusEnablePUA = Add-StatusCircle -x 320 -y 70 -color "Red"
$panel.Controls.Add($statusEnablePUA)

$checkboxEnableCloudProtection = New-Object System.Windows.Forms.CheckBox
$checkboxEnableCloudProtection.Text = "Activer la protection dans le cloud de Defender"
$checkboxEnableCloudProtection.Location = New-Object System.Drawing.Point(10, 100)
$checkboxEnableCloudProtection.Width = 300
$panel.Controls.Add($checkboxEnableCloudProtection)

$statusEnableCloudProtection = Add-StatusCircle -x 320 -y 100 -color "Red"
$panel.Controls.Add($statusEnableCloudProtection)

$checkboxEnableControlledFolderAccess = New-Object System.Windows.Forms.CheckBox
$checkboxEnableControlledFolderAccess.Text = "Activer l'accès contrôlé aux dossiers"
$checkboxEnableControlledFolderAccess.Location = New-Object System.Drawing.Point(10, 130)
$checkboxEnableControlledFolderAccess.Width = 300
$panel.Controls.Add($checkboxEnableControlledFolderAccess)

$statusEnableControlledFolderAccess = Add-StatusCircle -x 320 -y 130 -color "Red"
$panel.Controls.Add($statusEnableControlledFolderAccess)

$checkboxEnableBitLocker = New-Object System.Windows.Forms.CheckBox
$checkboxEnableBitLocker.Text = "Activer BitLocker"
$checkboxEnableBitLocker.Location = New-Object System.Drawing.Point(10, 160)
$checkboxEnableBitLocker.Width = 300
$panel.Controls.Add($checkboxEnableBitLocker)

$statusEnableBitLocker = Add-StatusCircle -x 320 -y 160 -color "Red"
$panel.Controls.Add($statusEnableBitLocker)

$labelTools = Add-Label -text "Logiciel a Installer :" -x 10 -y 190 -fontSize 14 -color "Green"
$panel.Controls.Add($labelTools)

$checkboxOffice365 = New-Object System.Windows.Forms.CheckBox
$checkboxOffice365.Text = "Installer Office365"
$checkboxOffice365.Location = New-Object System.Drawing.Point(10, 220)
$checkboxOffice365.Width = 300
$panel.Controls.Add($checkboxOffice365)

$statusOffice365 = Add-StatusCircle -x 320 -y 220 -color "Red"
$panel.Controls.Add($statusOffice365)

$checkboxAdobeReader = New-Object System.Windows.Forms.CheckBox
$checkboxAdobeReader.Text = "Installer AdobeReader"
$checkboxAdobeReader.Location = New-Object System.Drawing.Point(10, 250)
$checkboxAdobeReader.Width = 300
$panel.Controls.Add($checkboxAdobeReader)

$statusAdobeReader = Add-StatusCircle -x 320 -y 250 -color "Red"
$panel.Controls.Add($statusAdobeReader)

$checkboxInstallChrome = New-Object System.Windows.Forms.CheckBox
$checkboxInstallChrome.Text = "Installer Google Chrome"
$checkboxInstallChrome.Location = New-Object System.Drawing.Point(10, 280)
$checkboxInstallChrome.Width = 300
$panel.Controls.Add($checkboxInstallChrome)

$statusInstallChrome = Add-StatusCircle -x 320 -y 280 -color "Red"
$panel.Controls.Add($statusInstallChrome)

$checkboxInstallFirefox = New-Object System.Windows.Forms.CheckBox
$checkboxInstallFirefox.Text = "Installer Firefox"
$checkboxInstallFirefox.Location = New-Object System.Drawing.Point(10, 320)
$checkboxInstallFirefox.Width = 300
$panel.Controls.Add($checkboxInstallFirefox)

$statusInstallFirefox = Add-StatusCircle -x 320 -y 320 -color "Red"
$panel.Controls.Add($statusInstallFirefox)

$checkboxInstallCDBurnerXP = New-Object System.Windows.Forms.CheckBox
$checkboxInstallCDBurnerXP.Text = "Installer CDBurnerXP"
$checkboxInstallCDBurnerXP.Location = New-Object System.Drawing.Point(10, 350)
$checkboxInstallCDBurnerXP.Width = 300
$panel.Controls.Add($checkboxInstallCDBurnerXP)

$statusInstallCDBurnerXP = Add-StatusCircle -x 320 -y 350 -color "Red"
$panel.Controls.Add($statusInstallCDBurnerXP)

$checkboxInstallLibreOffice = New-Object System.Windows.Forms.CheckBox
$checkboxInstallLibreOffice.Text = "Installer LibreOffice"
$checkboxInstallLibreOffice.Location = New-Object System.Drawing.Point(10, 380)
$checkboxInstallLibreOffice.Width = 300
$panel.Controls.Add($checkboxInstallLibreOffice)

$statusInstallLibreOffice = Add-StatusCircle -x 320 -y 380 -color "Red"
$panel.Controls.Add($statusInstallLibreOffice)

$checkboxInstall7Zip = New-Object System.Windows.Forms.CheckBox
$checkboxInstall7Zip.Text = "Installer 7-Zip"
$checkboxInstall7Zip.Location = New-Object System.Drawing.Point(10, 410)
$checkboxInstall7Zip.Width = 300
$panel.Controls.Add($checkboxInstall7Zip)

$statusInstall7Zip = Add-StatusCircle -x 320 -y 410 -color "Red"
$panel.Controls.Add($statusInstall7Zip)

$checkboxInstallAnyDesk = New-Object System.Windows.Forms.CheckBox
$checkboxInstallAnyDesk.Text = "Installer AnyDesk"
$checkboxInstallAnyDesk.Location = New-Object System.Drawing.Point(10, 440)
$checkboxInstallAnyDesk.Width = 300
$panel.Controls.Add($checkboxInstallAnyDesk)

$statusInstallAnyDesk = Add-StatusCircle -x 320 -y 440 -color "Red"
$panel.Controls.Add($statusInstallAnyDesk)

$labelHarden2 = Add-Label -text "Optionnel :" -x 10 -y 470 -fontSize 14 -color "Blue"
$panel.Controls.Add($labelHarden2)

$checkboxConfigMagasin = New-Object System.Windows.Forms.CheckBox
$checkboxConfigMagasin.Text = "Configuration Magasin"
$checkboxConfigMagasin.Location = New-Object System.Drawing.Point(10, 500 )
$checkboxConfigMagasin.Width = 300
$panel.Controls.Add($checkboxConfigMagasin)

$statusConfigMagasin = Add-StatusCircle -x 320 -y 500 -color "Red"
$panel.Controls.Add($statusConfigMagasin)

$checkboxDisableDCOM = New-Object System.Windows.Forms.CheckBox
$checkboxDisableDCOM.Text = "Désactiver DCOM"
$checkboxDisableDCOM.Location = New-Object System.Drawing.Point(10, 530)
$checkboxDisableDCOM.Width = 300
$panel.Controls.Add($checkboxDisableDCOM)

$statusDisableDCOM = Add-StatusCircle -x 320 -y 530 -color "Red"
$panel.Controls.Add($statusDisableDCOM)

$checkboxDisableSMBv1 = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSMBv1.Text = "Désactiver SMBv1"
$checkboxDisableSMBv1.Location = New-Object System.Drawing.Point(10, 560)
$checkboxDisableSMBv1.Width = 300
$panel.Controls.Add($checkboxDisableSMBv1)

$statusDisableSMBv1 = Add-StatusCircle -x 320 -y 560 -color "Red"
$panel.Controls.Add($statusDisableSMBv1)

$checkboxEnableFirewall = New-Object System.Windows.Forms.CheckBox
$checkboxEnableFirewall.Text = "Activer le pare-feu Windows"
$checkboxEnableFirewall.Location = New-Object System.Drawing.Point(10, 590)
$checkboxEnableFirewall.Width = 300
$panel.Controls.Add($checkboxEnableFirewall)

$statusEnableFirewall = Add-StatusCircle -x 320 -y 590 -color "Red"
$panel.Controls.Add($statusEnableFirewall)

$labelPowerOptions = Add-Label -text "Veille :" -x 10 -y 620 -fontSize 14 -color "Green"
$panel.Controls.Add($labelPowerOptions)

$checkboxDisableScreenSaver = New-Object System.Windows.Forms.CheckBox
$checkboxDisableScreenSaver.Text = "Désactiver la mise en veille de l'écran"
$checkboxDisableScreenSaver.Location = New-Object System.Drawing.Point(10, 650)
$checkboxDisableScreenSaver.Width = 300
$panel.Controls.Add($checkboxDisableScreenSaver)

$statusDisableScreenSaver = Add-StatusCircle -x 320 -y 650 -color "Red"
$panel.Controls.Add($statusDisableScreenSaver)

$checkboxDisableSleep = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSleep.Text = "Désactiver la mise en veille du PC"
$checkboxDisableSleep.Location = New-Object System.Drawing.Point(10, 680)
$checkboxDisableSleep.Width = 300
$panel.Controls.Add($checkboxDisableSleep)

$statusDisableSleep = Add-StatusCircle -x 320 -y 680 -color "Red"
$panel.Controls.Add($statusDisableSleep)

$labelMaintenance = Add-Label -text "Maintenance :" -x 10 -y 710 -fontSize 14 -color "Purple"
$panel.Controls.Add($labelMaintenance)

$checkboxDeleteUpdateFolder = New-Object System.Windows.Forms.CheckBox
$checkboxDeleteUpdateFolder.Text = "Effacer le dossier Windows Update"
$checkboxDeleteUpdateFolder.Location = New-Object System.Drawing.Point(10, 740)
$checkboxDeleteUpdateFolder.Width = 300
$panel.Controls.Add($checkboxDeleteUpdateFolder)

$statusDeleteUpdateFolder = Add-StatusCircle -x 320 -y 740 -color "Red"
$panel.Controls.Add($statusDeleteUpdateFolder)

$checkboxDeletePIN = New-Object System.Windows.Forms.CheckBox
$checkboxDeletePIN.Text = "Effacer le PIN Windows"
$checkboxDeletePIN.Location = New-Object System.Drawing.Point(10, 770)
$checkboxDeletePIN.Width = 300
$panel.Controls.Add($checkboxDeletePIN)

$statusDeletePIN = Add-StatusCircle -x 320 -y 770 -color "Red"
$panel.Controls.Add($statusDeletePIN)

$checkboxDisableRemoteDesktop = New-Object System.Windows.Forms.CheckBox
$checkboxDisableRemoteDesktop.Text = "Désactiver le Bureau à distance"
$checkboxDisableRemoteDesktop.Location = New-Object System.Drawing.Point(10, 800)
$checkboxDisableRemoteDesktop.Width = 300
$panel.Controls.Add($checkboxDisableRemoteDesktop)

$statusDisableRemoteDesktop = Add-StatusCircle -x 320 -y 800 -color "Red"
$panel.Controls.Add($statusDisableRemoteDesktop)

$checkboxEnableHyperV = New-Object System.Windows.Forms.CheckBox
$checkboxEnableHyperV.Text = "Activer Hyper-V"
$checkboxEnableHyperV.Location = New-Object System.Drawing.Point(10, 830)
$checkboxEnableHyperV.Width = 300
$panel.Controls.Add($checkboxEnableHyperV)

$statusEnableHyperV = Add-StatusCircle -x 320 -y 830 -color "Red"
$panel.Controls.Add($statusEnableHyperV)

$checkboxClearEventLogs = New-Object System.Windows.Forms.CheckBox
$checkboxClearEventLogs.Text = "Effacer les journaux d'événements"
$checkboxClearEventLogs.Location = New-Object System.Drawing.Point(10, 860)
$checkboxClearEventLogs.Width = 300
$panel.Controls.Add($checkboxClearEventLogs)

$statusClearEventLogs = Add-StatusCircle -x 320 -y 860 -color "Red"
$panel.Controls.Add($statusClearEventLogs)

$checkboxEnableWSL = New-Object System.Windows.Forms.CheckBox
$checkboxEnableWSL.Text = "Activer WSL"
$checkboxEnableWSL.Location = New-Object System.Drawing.Point(10, 890)
$checkboxEnableWSL.Width = 300
$panel.Controls.Add($checkboxEnableWSL)

$statusEnableWSL = Add-StatusCircle -x 320 -y 890 -color "Red"
$panel.Controls.Add($statusEnableWSL)

$checkboxResetTCPIP = New-Object System.Windows.Forms.CheckBox
$checkboxResetTCPIP.Text = "Réinitialiser TCP/IP"
$checkboxResetTCPIP.Location = New-Object System.Drawing.Point(10, 920)
$checkboxResetTCPIP.Width = 300
$panel.Controls.Add($checkboxResetTCPIP)

$statusResetTCPIP = Add-StatusCircle -x 320 -y 920 -color "Red"
$panel.Controls.Add($statusResetTCPIP)

$labelNewOptions = Add-Label -text "Autre Options :" -x 10 -y 950 -fontSize 14 -color "Orange"
$panel.Controls.Add($labelNewOptions)

$checkboxDisableWindowsSearch = New-Object System.Windows.Forms.CheckBox
$checkboxDisableWindowsSearch.Text = "Désactiver Windows Search"
$checkboxDisableWindowsSearch.Location = New-Object System.Drawing.Point(10, 980)
$checkboxDisableWindowsSearch.Width = 300
$panel.Controls.Add($checkboxDisableWindowsSearch)

$statusDisableWindowsSearch = Add-StatusCircle -x 320 -y 980 -color "Red"
$panel.Controls.Add($statusDisableWindowsSearch)

$checkboxDisableSuperfetch = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSuperfetch.Text = "Désactiver Superfetch"
$checkboxDisableSuperfetch.Location = New-Object System.Drawing.Point(10, 1010)
$checkboxDisableSuperfetch.Width = 300
$panel.Controls.Add($checkboxDisableSuperfetch)

$statusDisableSuperfetch = Add-StatusCircle -x 320 -y 1010 -color "Red"
$panel.Controls.Add($statusDisableSuperfetch)

$checkboxDisableWindowsDefender = New-Object System.Windows.Forms.CheckBox
$checkboxDisableWindowsDefender.Text = "Désactiver Windows Defender"
$checkboxDisableWindowsDefender.Location = New-Object System.Drawing.Point(10, 1040)
$checkboxDisableWindowsDefender.Width = 300
$panel.Controls.Add($checkboxDisableWindowsDefender)

$statusDisableWindowsDefender = Add-StatusCircle -x 320 -y 1040 -color "Red"
$panel.Controls.Add($statusDisableWindowsDefender)

$checkboxEnableRDP = New-Object System.Windows.Forms.CheckBox
$checkboxEnableRDP.Text = "Activer le Bureau à distance"
$checkboxEnableRDP.Location = New-Object System.Drawing.Point(10, 1070)
$checkboxEnableRDP.Width = 300
$panel.Controls.Add($checkboxEnableRDP)

$statusEnableRDP = Add-StatusCircle -x 320 -y 1070 -color "Red"
$panel.Controls.Add($statusEnableRDP)

$checkboxEnableSystemRestore = New-Object System.Windows.Forms.CheckBox
$checkboxEnableSystemRestore.Text = "Activer la restauration du système"
$checkboxEnableSystemRestore.Location = New-Object System.Drawing.Point(10, 1100)
$checkboxEnableSystemRestore.Width = 300
$panel.Controls.Add($checkboxEnableSystemRestore)

$statusEnableSystemRestore = Add-StatusCircle -x 320 -y 1100 -color "Red"
$panel.Controls.Add($statusEnableSystemRestore)

$checkboxDisableSystemRestore = New-Object System.Windows.Forms.CheckBox
$checkboxDisableSystemRestore.Text = "Désactiver la restauration du système"
$checkboxDisableSystemRestore.Location = New-Object System.Drawing.Point(10, 1130)
$checkboxDisableSystemRestore.Width = 300
$panel.Controls.Add($checkboxDisableSystemRestore)

$statusDisableSystemRestore = Add-StatusCircle -x 320 -y 1130 -color "Red"
$panel.Controls.Add($statusDisableSystemRestore)

$checkboxDisableHibernation = New-Object System.Windows.Forms.CheckBox
$checkboxDisableHibernation.Text = "Désactiver l'hibernation"
$checkboxDisableHibernation.Location = New-Object System.Drawing.Point(10, 1160)
$checkboxDisableHibernation.Width = 300
$panel.Controls.Add($checkboxDisableHibernation)

$statusDisableHibernation = Add-StatusCircle -x 320 -y 1160 -color "Red"
$panel.Controls.Add($statusDisableHibernation)

$checkboxEnableHibernation = New-Object System.Windows.Forms.CheckBox
$checkboxEnableHibernation.Text = "Activer l'hibernation"
$checkboxEnableHibernation.Location = New-Object System.Drawing.Point(10, 1190)
$checkboxEnableHibernation.Width = 300
$panel.Controls.Add($checkboxEnableHibernation)

$statusEnableHibernation = Add-StatusCircle -x 320 -y 1190 -color "Red"
$panel.Controls.Add($statusEnableHibernation)

$checkboxDisableFastStartup = New-Object System.Windows.Forms.CheckBox
$checkboxDisableFastStartup.Text = "Désactiver le démarrage rapide"
$checkboxDisableFastStartup.Location = New-Object System.Drawing.Point(10, 1220)
$checkboxDisableFastStartup.Width = 300
$panel.Controls.Add($checkboxDisableFastStartup)

$statusDisableFastStartup = Add-StatusCircle -x 320 -y 1220 -color "Red"
$panel.Controls.Add($statusDisableFastStartup)

$checkboxEnableFastStartup = New-Object System.Windows.Forms.CheckBox
$checkboxEnableFastStartup.Text = "Activer le démarrage rapide"
$checkboxEnableFastStartup.Location = New-Object System.Drawing.Point(10, 1250)
$checkboxEnableFastStartup.Width = 300
$panel.Controls.Add($checkboxEnableFastStartup)

$statusEnableFastStartup = Add-StatusCircle -x 320 -y 1250 -color "Red"
$panel.Controls.Add($statusEnableFastStartup)

$logBox = New-Object System.Windows.Forms.RichTextBox
$logBox.Multiline = $true
$logBox.ScrollBars = "Vertical"
$logBox.Location = New-Object System.Drawing.Point(370, 40)
$logBox.Size = New-Object System.Drawing.Size(400, 400)
$logBox.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Regular)
$logBox.ReadOnly = $true
$panel.Controls.Add($logBox)

function Add-Log {
    param (
        [string]$message,
        [string]$color = "Black"
    )
    $logBox.SelectionStart = $logBox.TextLength
    $logBox.SelectionLength = 0
    $logBox.SelectionColor = [System.Drawing.Color]::FromName($color)
    $logBox.AppendText("$message`r`n")
    $logBox.SelectionColor = $logBox.ForeColor
}

function Update-Status {
    param (
        [System.Windows.Forms.PictureBox]$statusCircle,
        [bool]$isActivated
    )
    if ($isActivated) {
        $statusCircle.BackColor = [System.Drawing.Color]::Green
    } else {
        $statusCircle.BackColor = [System.Drawing.Color]::Red
    }
}

# Fonction pour vérifier l'état de la restauration du système
function Get-ComputerRestoreStatus {
    param (
        [string]$Drive
    )
    $status = Enable-ComputerRestore -Drive $Drive -WhatIf 2>&1
    if ($status -like "*Enable-ComputerRestore*") {
        return $true
    } else {
        return $false
    }
}

# Fonction pour vérifier l'état de l'hibernation
function Get-HibernationStatus {
    $status = powercfg /query SCHEME_CURRENT SUB_SLEEP STANDBYIDLE 2>&1
    if ($status -like "*No*") {
        return $false
    } else {
        return $true
    }
}

# Fonction pour vérifier l'état du démarrage rapide
function Get-FastStartupStatus {
    $status = powercfg /query SCHEME_CURRENT SUB_SLEEP HYBRIDLEEP 2>&1
    if ($status -like "*No*") {
        return $false
    } else {
        return $true
    }
}

function Check-FeatureStatus {
    param (
        [string]$feature
    )
    switch ($feature) {
        "PUAProtection" {
            return ((Get-MpPreference).PUAProtection -eq "Enabled")
        }
        "MAPSReporting" {
            return ((Get-MpPreference).MAPSReporting -eq "Advanced")
        }
        "EnableControlledFolderAccess" {
            return ((Get-MpPreference).EnableControlledFolderAccess -eq "Enabled")
        }
        "BitLocker" {
            return ((Get-BitLockerVolume -MountPoint "C:").VolumeStatus -eq "FullyEncrypted")
        }
        "Hibernation" {
            return Get-HibernationStatus
        }
        "FastStartup" {
            return Get-FastStartupStatus
        }
        "SystemRestore" {
            return Get-ComputerRestoreStatus -Drive "C:\"
        }
        default {
            return $false
        }
    }
}

# Check the current status of each feature
Update-Status -statusCircle $statusBatteryReport -isActivated $false
Update-Status -statusCircle $statusEnablePUA -isActivated (Check-FeatureStatus -feature "PUAProtection")
Update-Status -statusCircle $statusEnableCloudProtection -isActivated (Check-FeatureStatus -feature "MAPSReporting")
Update-Status -statusCircle $statusEnableControlledFolderAccess -isActivated (Check-FeatureStatus -feature "EnableControlledFolderAccess")
Update-Status -statusCircle $statusEnableBitLocker -isActivated (Check-FeatureStatus -feature "BitLocker")

Update-Status -statusCircle $statusDisableHibernation -isActivated (-not (Check-FeatureStatus -feature "Hibernation"))
Update-Status -statusCircle $statusEnableHibernation -isActivated (Check-FeatureStatus -feature "Hibernation")
Update-Status -statusCircle $statusDisableFastStartup -isActivated (-not (Check-FeatureStatus -feature "FastStartup"))
Update-Status -statusCircle $statusEnableFastStartup -isActivated (Check-FeatureStatus -feature "FastStartup")
Update-Status -statusCircle $statusEnableSystemRestore -isActivated (Check-FeatureStatus -feature "SystemRestore")
Update-Status -statusCircle $statusDisableSystemRestore -isActivated (-not (Check-FeatureStatus -feature "SystemRestore"))

# Vérifiez si la restauration du système est activée
$systemRestoreStatus = Get-ComputerRestoreStatus -Drive "C:\"
Update-Status -statusCircle $statusEnableSystemRestore -isActivated $systemRestoreStatus
Update-Status -statusCircle $statusDisableSystemRestore -isActivated (-not $systemRestoreStatus)

# Vérifiez l'état de l'hibernation
$hibernationStatus = Get-HibernationStatus
Update-Status -statusCircle $statusDisableHibernation -isActivated (-not $hibernationStatus)
Update-Status -statusCircle $statusEnableHibernation -isActivated $hibernationStatus

# Vérifiez l'état du démarrage rapide
$fastStartupStatus = Get-FastStartupStatus
Update-Status -statusCircle $statusDisableFastStartup -isActivated (-not $fastStartupStatus)
Update-Status -statusCircle $statusEnableFastStartup -isActivated $fastStartupStatus


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
            Update-Status -statusCircle $statusBatteryReport -isActivated $true
        } catch {
            Add-Log "Erreur lors de la génération du rapport de batterie : $_"
        }
    }
    if ($checkboxEnablePUA.Checked) {
        Add-Log "Activation des signatures PUA de Defender..."
        try {
            Set-MpPreference -PUAProtection Enabled
            Add-Log "Signatures PUA activées."
            Update-Status -statusCircle $statusEnablePUA -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation des signatures PUA de Defender : $_"
        }
    }
    if ($checkboxEnableCloudProtection.Checked) {
        Add-Log "Activation de la protection dans le cloud de Defender..."
        try {
            Set-MpPreference -MAPSReporting Advanced
            Add-Log "Protection cloud activée."
            Update-Status -statusCircle $statusEnableCloudProtection -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation de la protection dans le cloud de Defender : $_"
        }
    }
    if ($checkboxEnableControlledFolderAccess.Checked) {
        Add-Log "Activation de l'accès contrôlé aux dossiers..."
        try {
            Set-MpPreference -EnableControlledFolderAccess Enabled
            Add-Log "Accès contrôlé aux dossiers activé."
            Update-Status -statusCircle $statusEnableControlledFolderAccess -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation de l'accès contrôlé aux dossiers : $_"
        }
    }
    if ($checkboxEnableBitLocker.Checked) {
        Add-Log "Activation de BitLocker..."
        try {
            Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256
            Add-Log "BitLocker activé."
            Update-Status -statusCircle $statusEnableBitLocker -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation de BitLocker : $_"
        }
    }
    if ($checkboxInstallChrome.Checked) {
        Add-Log "Installation de Google Chrome..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi /qn" -Wait
            Add-Log "Google Chrome installé."
            Update-Status -statusCircle $statusInstallChrome -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation de Google Chrome : $_"
        }
    }
    if ($checkboxOffice365.Checked) {
        Add-Log "Installation de Microsoft Office 365..."
        try {
            $officeDeploymentToolUrl = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?productReleaseID=HomeBusinessRetail&platform=X64&language=fr-ca&TaxRegion=pr&correlationId=6c9987bc-6b60-435e-bd02-55bbd2f99308&token=faaf32f6-6d4e-437a-8829-62f924252076&version=O16GA&source=O15OLSOMEX"
            $downloadPath = "$env:TEMP\OfficeDeploymentTool.exe"
            $installFolder = "$env:ProgramFiles\OfficeDeploymentTool"
            $configurationFilePath = "$installFolder\configuration.xml"
            if (-not (Test-Path -Path $installFolder)) {
                New-Item -ItemType Directory -Path $installFolder -Force
            }
            Add-Log "Downloading Office Deployment Tool..."
            Invoke-WebRequest -Uri $officeDeploymentToolUrl -OutFile $downloadPath
            Add-Log "Extracting Office Deployment Tool..."
            Start-Process -FilePath $downloadPath -ArgumentList "/quiet" -Wait
            $xmlContent = "<Configuration><Add OfficeClientEdition='64' Channel='MonthlyEnterprise'><Product ID='O365ProPlusRetail'><Language ID='fr-ca' /></Product></Add><Display Level='None' AcceptEULA='TRUE' /><Property Name='AUTOACTIVATE' Value='1' /></Configuration>"
            Set-Content -Path $configurationFilePath -Value $xmlContent
            Add-Log "Starting silent installation of Microsoft Office 365..."
            $setupExePath = "$installFolder\setup.exe"
            Start-Process -FilePath $setupExePath -ArgumentList "/configure `"$configurationFilePath`"" -Wait
            Add-Log "Microsoft Office 365 installation completed successfully."
            Update-Status -statusCircle $statusOffice365 -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation de Microsoft Office 365 : $_"
        }
    }

    if ($checkboxAdobeReader.Checked) {
        Add-Log "Installation d'Adobe Acrobat Reader..."
        try {
            $adobeReaderUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2300320269/AcroRdrDCx642300320269_en_US.exe"
            $downloadPath = "$env:TEMP\AdobeReaderInstaller.exe"
            Add-Log "Downloading Adobe Acrobat Reader..."
            Invoke-Expression "curl -o $downloadPath $adobeReaderUrl"
            Add-Log "Installing Adobe Acrobat Reader..."
            Start-Process -FilePath $downloadPath -ArgumentList "/sAll /rs /rps /msi EULA_ACCEPT=YES" -Wait
            $readerExePath = "$env:ProgramFiles\Adobe\Acrobat Reader DC\Reader\AcroRd32.exe"
            if (-not (Test-Path -Path $readerExePath)) {
                Add-Log "The Adobe Acrobat Reader executable was not found."
                exit
            }
            Add-Log "Starting Adobe Acrobat Reader..."
            Start-Process -FilePath $readerExePath -Wait
            Add-Log "Adobe Acrobat Reader installation completed successfully."
            Update-Status -statusCircle $statusAdobeReader -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation d'Adobe Acrobat Reader : $_"
        }
    }

    if ($checkboxInstallFirefox.Checked) {
        Add-Log "Installation de Mozilla Firefox..."
        try {
            # Définir l'URL de téléchargement et le chemin de destination
            $firefoxUrl = "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US"
            $destination = "$env:TEMP\firefox_installer.exe"

            # Définir les en-têtes
            $headers = @{
                "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0"
                "Accept" = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
                "Accept-Language" = "en-US,en;q=0.5"
                "Connection" = "keep-alive"
                "Upgrade-Insecure-Requests" = "1"
            }
            Invoke-WebRequest -Uri $firefoxUrl -OutFile $destination -Headers $headers
            Start-Process -FilePath $destination -ArgumentList "/S" -Wait
            Remove-Item $destination

            Add-Log "Mozilla Firefox installé."
            Update-Status -statusCircle $statusInstallFirefox -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation de Mozilla Firefox : $_"
        }
    }
    if ($checkboxInstallCDBurnerXP.Checked) {
        Add-Log "Installation de CDBurnerXP..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.cdburnerxp.se/setup_x64.exe /qn" -Wait
            Add-Log "CDBurnerXP installé."
            Update-Status -statusCircle $statusInstallCDBurnerXP -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation de CDBurnerXP : $_"
        }
    }
    if ($checkboxInstallLibreOffice.Checked) {
        Add-Log "Installation de LibreOffice..."
        try {
            $libreOfficeUrl = "https://download.documentfoundation.org/libreoffice/stable/7.5.0/win/x86_64/LibreOffice_7.5.0_Win_x64.msi"  # Exemple d'URL, à vérifier sur le site officiel
            $destination = "$env:TEMP\LibreOffice_7.4.6_Win_x64.msi"
            Invoke-WebRequest -Uri $libreOfficeUrl -OutFile $destination
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$destination`" /qn" -Wait
            Remove-Item $destination
            Add-Log "LibreOffice installé."
            Update-Status -statusCircle $statusInstallLibreOffice -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation de LibreOffice : $_"
        }
    }
    if ($checkboxInstall7Zip.Checked) {
        Add-Log "Installation de 7-Zip..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://www.7-zip.org/a/7z1900-x64.msi /qn" -Wait
            Add-Log "7-Zip installé."
            Update-Status -statusCircle $statusInstall7Zip -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation de 7-Zip : $_"
        }
    }
    if ($checkboxInstallAnyDesk.Checked) {
        Add-Log "Installation d'AnyDesk..."
        try {
            Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.anydesk.com/AnyDesk.msi /qn" -Wait
            Add-Log "AnyDesk installé."
            Update-Status -statusCircle $statusInstallAnyDesk -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'installation d'AnyDesk : $_"
        }
    }
    if ($checkboxConfigMagasin.Checked) {
        Add-Log "Configuration par défaut pour navigateur et PDF..."
        try {
            $chromeProgId = "ChromeHTML"

            # Créer les chemins de registre si nécessaire et définir les valeurs
            $paths = @(
                "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice",
                "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice",
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice"
            )

            foreach ($path in $paths) {
                if (-not (Test-Path $path)) {
                    $parentPath = [System.IO.Path]::GetDirectoryName($path)
                    if (-not (Test-Path $parentPath)) {
                        New-Item -Path $parentPath -Force
                    }
                    New-Item -Path $path -Force
                }
            }

            Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice" -Name ProgId -Value $chromeProgId
            Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name ProgId -Value $chromeProgId
            $pdfProgId = "AcroExch.Document.DC"
            Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.pdf\UserChoice" -Name ProgId -Value $pdfProgId

            $desktopItems = @(
                "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}", # This PC
                "shell:::{59031a47-3f72-44a7-89c5-5595fe6b30ee}" # User Folder
            )

            foreach ($item in $desktopItems) {
                $shell = New-Object -ComObject Shell.Application
                $folder = $shell.Namespace('Desktop')
                $folder.Self.InvokeVerb("Paste")
                New-Item -Path "$env:USERPROFILE\Desktop" -Name $item -ItemType SymbolicLink -Value $item -Force
            }

            Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update" -Name AUOptions -Value 4

            $autorunPaths = @(
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
                "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
            )

            foreach ($path in $autorunPaths) {
                if (Test-Path "$path\AnyDesk") {
                    Remove-ItemProperty -Path $path -Name "AnyDesk" -Force
                }
                if (Test-Path "$path\Adobe Reader") {
                    Remove-ItemProperty -Path $path -Name "Adobe Reader" -Force
                }
            }

            $startMenuItems = @(
                "shell:::{D9EF8727-CAC2-4e60-809E-86F80A666C91}", # Settings
                "shell:::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" # File Explorer
            )

            foreach ($item in $startMenuItems) {
                $startMenuShell = New-Object -ComObject Shell.Application
                $startMenuNamespace = $startMenuShell.NameSpace('Shell:AppsFolder')
                $startMenuNamespace.Self.InvokeVerb("Paste")
                New-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Name $item -ItemType SymbolicLink -Value $item -Force
            }

            Add-Log "Configuration par défaut complétée avec succès."
            Update-Status -statusCircle $statusConfigMagasin -isActivated $true
        } catch {
            Add-Log "Erreur lors de la configuration : $_"
        }
    }


    if ($checkboxDisableDCOM.Checked) {
        Add-Log "Désactivation de DCOM..."
        try {
            Set-ItemProperty -Path "HKLM:\Software\Microsoft\Ole" -Name "EnableDCOM" -Value "N"
            Add-Log "DCOM désactivé."
            Update-Status -statusCircle $statusDisableDCOM -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation de DCOM : $_"
        }
    }
    if ($checkboxDisableSMBv1.Checked) {
        Add-Log "Désactivation de SMBv1..."
        try {
            Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
            Add-Log "SMBv1 désactivé."
            Update-Status -statusCircle $statusDisableSMBv1 -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation de SMBv1 : $_"
        }
    }
    if ($checkboxEnableFirewall.Checked) {
        Add-Log "Activation du pare-feu Windows..."
        try {
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
            Add-Log "Pare-feu Windows activé."
            Update-Status -statusCircle $statusEnableFirewall -isActivated $true
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
            Update-Status -statusCircle $statusDisableScreenSaver -isActivated $true
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
            Update-Status -statusCircle $statusDisableSleep -isActivated $true
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
            Update-Status -statusCircle $statusDeleteUpdateFolder -isActivated $true
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
            Update-Status -statusCircle $statusDeletePIN -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'effacement du PIN Windows : $_"
        }
    }
    if ($checkboxDisableRemoteDesktop.Checked) {
        Add-Log "Désactivation du Bureau à distance..."
        try {
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1
            Add-Log "Bureau à distance désactivé."
            Update-Status -statusCircle $statusDisableRemoteDesktop -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation du Bureau à distance : $_"
        }
    }
    if ($checkboxEnableHyperV.Checked) {
        Add-Log "Activation de Hyper-V..."
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -NoRestart
            Add-Log "Hyper-V activé."
            Update-Status -statusCircle $statusEnableHyperV -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation de Hyper-V : $_"
        }
    }
    if ($checkboxClearEventLogs.Checked) {
        Add-Log "Effacement des journaux d'événements..."
        try {
            wevtutil el | Foreach-Object {wevtutil cl "$_"}
            Add-Log "Journaux d'événements effacés."
            Update-Status -statusCircle $statusClearEventLogs -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'effacement des journaux d'événements : $_"
        }
    }
    if ($checkboxEnableWSL.Checked) {
        Add-Log "Activation du sous-système Windows pour Linux (WSL)..."
        try {
            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
            Add-Log "WSL activé."
            Update-Status -statusCircle $statusEnableWSL -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation du sous-système Windows pour Linux (WSL) : $_"
        }
    }
    if ($checkboxResetTCPIP.Checked) {
        Add-Log "Réinitialisation des paramètres TCP/IP..."
        try {
            netsh int ip reset
            Add-Log "Paramètres TCP/IP réinitialisés."
            Update-Status -statusCircle $statusResetTCPIP -isActivated $true
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
            Update-Status -statusCircle $statusDisableWindowsSearch -isActivated $true
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
            Update-Status -statusCircle $statusDisableSuperfetch -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation de Superfetch : $_"
        }
    }
    if ($checkboxDisableWindowsDefender.Checked) {
        Add-Log "Désactivation de Windows Defender..."
        try {
            Set-MpPreference -DisableRealtimeMonitoring $true
            Add-Log "Windows Defender désactivé."
            Update-Status -statusCircle $statusDisableWindowsDefender -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation de Windows Defender : $_"
        }
    }
    if ($checkboxEnableRDP.Checked) {
        Add-Log "Activation du Bureau à distance..."
        try {
            Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
            Add-Log "Bureau à distance activé."
            Update-Status -statusCircle $statusEnableRDP -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation du Bureau à distance : $_"
        }
    }
    if ($checkboxEnableSystemRestore.Checked) {
        Add-Log "Activation de la restauration du système..."
        try {
            Enable-ComputerRestore -Drive "C:\"
            Add-Log "Restauration du système activée."
            Update-Status -statusCircle $statusEnableSystemRestore -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation de la restauration du système : $_"
        }
    }
    if ($checkboxDisableSystemRestore.Checked) {
        Add-Log "Désactivation de la restauration du système..."
        try {
            Disable-ComputerRestore -Drive "C:\"
            Add-Log "Restauration du système désactivée."
            Update-Status -statusCircle $statusDisableSystemRestore -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation de la restauration du système : $_"
        }
    }
    if ($checkboxDisableHibernation.Checked) {
        Add-Log "Désactivation de l'hibernation..."
        try {
            powercfg -h off
            Add-Log "Hibernation désactivée."
            Update-Status -statusCircle $statusDisableHibernation -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation de l'hibernation : $_"
        }
    }
    if ($checkboxEnableHibernation.Checked) {
        Add-Log "Activation de l'hibernation..."
        try {
            powercfg -h on
            Add-Log "Hibernation activée."
            Update-Status -statusCircle $statusEnableHibernation -isActivated $true
        } catch {
            Add-Log "Erreur lors de l'activation de l'hibernation : $_"
        }
    }
    if ($checkboxDisableFastStartup.Checked) {
        Add-Log "Désactivation du démarrage rapide..."
        try {
            powercfg -h off
            Add-Log "Démarrage rapide désactivé."
            Update-Status -statusCircle $statusDisableFastStartup -isActivated $true
        } catch {
            Add-Log "Erreur lors de la désactivation du démarrage rapide : $_"
        }
    }
    if ($checkboxEnableFastStartup.Checked) {
        Add-Log "Activation du démarrage rapide..."
        try {
            powercfg -h on
            Add-Log "Démarrage rapide activé."
            Update-Status -statusCircle $statusEnableFastStartup -isActivated $true
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

$form.ShowDialog()
