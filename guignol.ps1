Add-Type -AssemblyName System.Windows.Forms

# Créer la fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Commandes PowerShell GUI"
$form.Size = New-Object System.Drawing.Size(400, 500)

# Créer des cases à cocher pour différentes commandes (section durcissement)
$checkboxBatteryReport = New-Object System.Windows.Forms.CheckBox
$checkboxBatteryReport.Text = "Générer un rapport de batterie"
$checkboxBatteryReport.Location = New-Object System.Drawing.Point(10, 10)
$form.Controls.Add($checkboxBatteryReport)

$checkboxEnablePUA = New-Object System.Windows.Forms.CheckBox
$checkboxEnablePUA.Text = "Activer les signatures PUA de Defender"
$checkboxEnablePUA.Location = New-Object System.Drawing.Point(10, 40)
$form.Controls.Add($checkboxEnablePUA)

$checkboxEnableCloudProtection = New-Object System.Windows.Forms.CheckBox
$checkboxEnableCloudProtection.Text = "Activer la protection dans le cloud de Defender"
$checkboxEnableCloudProtection.Location = New-Object System.Drawing.Point(10, 70)
$form.Controls.Add($checkboxEnableCloudProtection)

$checkboxEnableControlledFolderAccess = New-Object System.Windows.Forms.CheckBox
$checkboxEnableControlledFolderAccess.Text = "Activer l'accès contrôlé aux dossiers"
$checkboxEnableControlledFolderAccess.Location = New-Object System.Drawing.Point(10, 100)
$form.Controls.Add($checkboxEnableControlledFolderAccess)

$checkboxEnableBitLocker = New-Object System.Windows.Forms.CheckBox
$checkboxEnableBitLocker.Text = "Activer BitLocker"
$checkboxEnableBitLocker.Location = New-Object System.Drawing.Point(10, 130)
$form.Controls.Add($checkboxEnableBitLocker)

# Section pour l'installation des outils
$labelTools = New-Object System.Windows.Forms.Label
$labelTools.Text = "Outils à installer :"
$labelTools.Location = New-Object System.Drawing.Point(10, 160)
$form.Controls.Add($labelTools)

$checkboxInstallChrome = New-Object System.Windows.Forms.CheckBox
$checkboxInstallChrome.Text = "Installer Google Chrome"
$checkboxInstallChrome.Location = New-Object System.Drawing.Point(10, 190)
$form.Controls.Add($checkboxInstallChrome)

$checkboxInstallFirefox = New-Object System.Windows.Forms.CheckBox
$checkboxInstallFirefox.Text = "Installer Firefox"
$checkboxInstallFirefox.Location = New-Object System.Drawing.Point(10, 220)
$form.Controls.Add($checkboxInstallFirefox)

$checkboxInstallCDBurnerXP = New-Object System.Windows.Forms.CheckBox
$checkboxInstallCDBurnerXP.Text = "Installer CDBurnerXP"
$checkboxInstallCDBurnerXP.Location = New-Object System.Drawing.Point(10, 250)
$form.Controls.Add($checkboxInstallCDBurnerXP)

$checkboxInstallLibreOffice = New-Object System.Windows.Forms.CheckBox
$checkboxInstallLibreOffice.Text = "Installer LibreOffice"
$checkboxInstallLibreOffice.Location = New-Object System.Drawing.Point(10, 280)
$form.Controls.Add($checkboxInstallLibreOffice)

$checkboxInstall7Zip = New-Object System.Windows.Forms.CheckBox
$checkboxInstall7Zip.Text = "Installer 7-Zip"
$checkboxInstall7Zip.Location = New-Object System.Drawing.Point(10, 310)
$form.Controls.Add($checkboxInstall7Zip)

$checkboxInstallAnyDesk = New-Object System.Windows.Forms.CheckBox
$checkboxInstallAnyDesk.Text = "Installer AnyDesk"
$checkboxInstallAnyDesk.Location = New-Object System.Drawing.Point(10, 340)
$form.Controls.Add($checkboxInstallAnyDesk)

# Bouton Appliquer
$applyButton = New-Object System.Windows.Forms.Button
$applyButton.Text = "Appliquer"
$applyButton.Location = New-Object System.Drawing.Point(10, 370)
$applyButton.Add_Click({
    if ($checkboxBatteryReport.Checked) {
        Write-Output "Génération du rapport de batterie..."
        powercfg /batteryreport
        Write-Output "Rapport de batterie généré."
    }
    if ($checkboxEnablePUA.Checked) {
        Write-Output "Activation des signatures PUA de Defender..."
        Set-MpPreference -PUAProtection 1
        Write-Output "Signatures PUA de Defender activées."
    }
    if ($checkboxEnableCloudProtection.Checked) {
        Write-Output "Activation de la protection dans le cloud de Defender..."
        Set-MpPreference -MAPSReporting Advanced
        Write-Output "Protection dans le cloud de Defender activée."
    }
    if ($checkboxEnableControlledFolderAccess.Checked) {
        Write-Output "Activation de l'accès contrôlé aux dossiers..."
        Set-MpPreference -EnableControlledFolderAccess Enabled
        Write-Output "Accès contrôlé aux dossiers activé."
    }
    if ($checkboxEnableBitLocker.Checked) {
        Write-Output "Activation de BitLocker..."
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes128 -UsedSpaceOnly
        Write-Output "BitLocker activé."
    }
    if ($checkboxInstallChrome.Checked) {
        Write-Output "Installation de Google Chrome..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://dl.google.com/tag/s/appguid%3D%7B3C81510D-33F3-432E-A5BB-919EE9994321%7D%26iid%3D%7B5805C1F1-87DA-43E3-8140-BF7E4D3D2B33%7D%26lang%3Dfr%26browser%3D3%26usagestats%3D0%26appname%3DGoogle%2520Chrome%26needsadmin%3Dprefers/GoogleChromeStandaloneEnterprise64.msi /qn" -Wait
        Write-Output "Google Chrome installé."
    }
    if ($checkboxInstallFirefox.Checked) {
        Write-Output "Installation de Firefox..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=fr /qn" -Wait
        Write-Output "Firefox installé."
    }
    if ($checkboxInstallCDBurnerXP.Checked) {
        Write-Output "Installation de CDBurnerXP..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.cdburnerxp.se/CDBurnerXP-x64-setup.exe /silent /loadinf=setup.inf /MERGETASKS=!desktopicon /norestart" -Wait
        Write-Output "CDBurnerXP installé."
    }
    if ($checkboxInstallLibreOffice.Checked) {
        Write-Output "Installation de LibreOffice..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.documentfoundation.org/libreoffice/stable/7.1.6/win/x86_64/LibreOffice_7.1.6_Win_x64.msi /qn" -Wait
        Write-Output "LibreOffice installé."
    }
    if ($checkboxInstall7Zip.Checked) {
        Write-Output "Installation de 7-Zip..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://www.7-zip.org/a/7z1900-x64.msi /qn" -Wait
        Write-Output "7-Zip installé."
    }
    if ($checkboxInstallAnyDesk.Checked) {
        Write-Output "Installation de AnyDesk..."
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/i https://download.anydesk.com/AnyDesk.msi /qn" -Wait
        Write-Output "AnyDesk installé."
    }
    [System.Windows.Forms.MessageBox]::Show("Commandes appliquées.")
})

$form.Controls.Add($applyButton)

# Afficher le formulaire
$form.Add_Shown({$form.Activate()})
[System.Windows.Forms.Application]::Run($form)