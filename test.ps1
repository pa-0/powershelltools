Add-Type -AssemblyName PresentationFramework

# Create the window
$window = New-Object Windows.Window
$window.Title = "Windows 10 Security Hardening and Software Installation"
$window.Width = 800
$window.Height = 600
$window.WindowStartupLocation = "CenterScreen"

# Create the main grid
$grid = New-Object Windows.Controls.Grid
$grid.Margin = "10"

# Define rows and columns
for ($i = 0; $i -lt 8; $i++) {
    $row = New-Object Windows.Controls.RowDefinition
    $row.Height = [Windows.GridLength]::Auto
    $grid.RowDefinitions.Add($row)
}

for ($i = 0; $i -lt 3; $i++) {
    $col = New-Object Windows.Controls.ColumnDefinition
    if ($i -eq 2) {
        $col.Width = New-Object Windows.GridLength(1, [Windows.GridUnitType]::Star)
    } else {
        $col.Width = New-Object Windows.GridLength(200)
    }
    $grid.ColumnDefinitions.Add($col)
}

# Create checkboxes for security options
$securityOptions = @("Block remote commands", "Change file associations", "Enable Windows Defender settings", "Enable Exploit Guard", "Harden Office", "General OS hardening", "Advanced Windows logging", "Windows 10 Privacy Settings")
$checkboxes = @{}

for ($i = 0; $i -lt $securityOptions.Length; $i++) {
    $checkbox = New-Object Windows.Controls.CheckBox
    $checkbox.Content = $securityOptions[$i]
    $checkbox.Margin = "5"
    [Windows.Controls.Grid]::SetRow($checkbox, [int]([Math]::Floor($i / 2)))
    [Windows.Controls.Grid]::SetColumn($checkbox, $i % 2)
    $grid.Children.Add($checkbox)
    $checkboxes += $checkbox
}

# Create checkboxes for software installation
$softwareOptions = @("Notepad++", "Google Chrome", "Mozilla Firefox", "Adobe Reader", "7-Zip", "WinRAR", "VLC Player")
$softwareCheckboxes = @{}

for ($i = 0; $i -lt $softwareOptions.Length; $i++) {
    $checkbox = New-Object Windows.Controls.CheckBox
    $checkbox.Content = $softwareOptions[$i]
    $checkbox.Margin = "5"
    [Windows.Controls.Grid]::SetRow($checkbox, [int]([Math]::Floor(($i + $securityOptions.Length) / 2)))
    [Windows.Controls.Grid]::SetColumn($checkbox, ($i + $securityOptions.Length) % 2)
    $grid.Children.Add($checkbox)
    $softwareCheckboxes += $checkbox
}

# Create Select All and Clear All buttons
$selectAllButton = New-Object Windows.Controls.Button
$selectAllButton.Content = "Select All"
$selectAllButton.Margin = "5"
[Windows.Controls.Grid]::SetRow($selectAllButton, [int]([Math]::Floor(($securityOptions.Length + $softwareOptions.Length) / 2)))
[Windows.Controls.Grid]::SetColumn($selectAllButton, 0)
$grid.Children.Add($selectAllButton)

$clearAllButton = New-Object Windows.Controls.Button
$clearAllButton.Content = "Clear All"
$clearAllButton.Margin = "5"
[Windows.Controls.Grid]::SetRow($clearAllButton, [int]([Math]::Floor(($securityOptions.Length + $softwareOptions.Length) / 2)))
[Windows.Controls.Grid]::SetColumn($clearAllButton, 1)
$grid.Children.Add($clearAllButton)

# Create the Submit button
$submitButton = New-Object Windows.Controls.Button
$submitButton.Content = "Submit"
$submitButton.Margin = "5"
[Windows.Controls.Grid]::SetRow($submitButton, 7)
[Windows.Controls.Grid]::SetColumn($submitButton, 1)
$grid.Children.Add($submitButton)

# Add grid to window
$window.Content = $grid

# Event handlers for Select All and Clear All buttons
$selectAllButton.Add_Click({
    foreach ($checkbox in $checkboxes + $softwareCheckboxes) {
        $checkbox.IsChecked = $true
    }
})

$clearAllButton.Add_Click({
    foreach ($checkbox in $checkboxes + $softwareCheckboxes) {
        $checkbox.IsChecked = $false
    }
})

# Submit button click event
$submitButton.Add_Click({
    $selectedSecurityOptions = @{}
    for ($i = 0; $i -lt $securityOptions.Length; $i++) {
        if ($checkboxes[$i].IsChecked -eq $true) {
            $selectedSecurityOptions[$securityOptions[$i]] = $true
        }
    }
    $selectedSoftwareOptions = @{}
    for ($i = 0; $i -lt $softwareOptions.Length; $i++) {
        if ($softwareCheckboxes[$i].IsChecked -eq $true) {
            $selectedSoftwareOptions[$softwareOptions[$i]] = $true
        }
    }
    $window.Close()

    # Apply security settings
    if ($selectedSecurityOptions["Block remote commands"]) {
        reg add HKEY_LOCAL_MACHINE\Software\Microsoft\OLE /v EnableDCOM /t REG_SZ /d N /F
    }
    if ($selectedSecurityOptions["Change file associations"]) {
        assoc .bat=txtfile
        assoc .cmd=txtfile
        assoc .chm=txtfile
        assoc .hta=txtfile
        assoc .jse=txtfile
        assoc .js=txtfile
        assoc .vbe=txtfile
        assoc .vbs=txtfile
        assoc .wsc=txtfile
        assoc .wsf=txtfile
        assoc .ws=txtfile
        assoc .wsh=txtfile
        assoc .scr=txtfile
        assoc .url=txtfile
        assoc .ps1=txtfile
        assoc .iso=txtfile
        assoc .reg=txtfile
        assoc .wcx=txtfile
        assoc .slk=txtfile
        assoc .iqy=txtfile
        assoc .prn=txtfile
        assoc .diff=txtfile
        assoc .rdg=txtfile
        assoc .deploy=txtfile
    }
    if ($selectedSecurityOptions["Enable Windows Defender settings"]) {
        setx /M MP_FORCE_USE_SANDBOX 1
        "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
        powershell.exe Set-MpPreference -PUAProtection enable
        reg add "HKCU\SOFTWARE\Microsoft\Windows Defender" /v PassiveMode /t REG_DWORD /d 2 /f
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids D4F940AB-401B-4EFC-AADC-AD5F3C50688A -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 75668C1F-73B5-4CF0-BB93-3ECF5CB7CC84 -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 92E97FA1-2EDF-4476-BDD6-9DD0B4DDDC7B -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 3B576869-A4EC-4529-8536-B80A7769E899 -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 5BEB7EFE-FD9A-4556-801D-275E5FFC04CC -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550 -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids D3E037E1-3EB8-44C8-A917-57927947596D -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 01443614-cd74-433a-b99e-2ecdc07bfc25 -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids C1DB55AB-C21A-4637-BB3F-A12568109D35 -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids 9E6C4E1F-7D60-472F-BA1A-A39EF669E4B2 -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Add-MpPreference -AttackSurfaceReductionRules_Ids B2B3F03D-6A65-4F7B-A9C7-1C7EF74A9BA4 -AttackSurfaceReductionRules_Actions Enabled
        powershell.exe Set-MpPreference -EnableControlledFolderAccess Enabled
        powershell.exe Add-MpPreference -ControlledFolderAccessProtectedFolders "C:\Users\Public", "C:\Users\%username%\Documents"
    }
    if ($selectedSecurityOptions["Enable Exploit Guard"]) {
        reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Attack Surface Reduction\System Overrides" /v SecurityHealthService /t REG_DWORD /d 1 /f
        reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Windows Defender Exploit Guard\Network Protection" /v EnableNetworkProtection /t REG_DWORD /d 1 /f
        powershell.exe Set-MpPreference -EnableNetworkProtection Enabled
        powershell.exe New-CIPolicy -Level PcaCertificate -FilePath "C:\Windows\System32\CodeIntegrity\CIPolicy.xml" -UserPEs $false
    }
    if ($selectedSecurityOptions["Harden Office"]) {
        reg add "HKCU\Software\Microsoft\Office\16.0\Excel\Security\FileValidation" /v EnableOnLoad /t REG_DWORD /d 1 /f
        reg add "HKCU\Software\Microsoft\Office\16.0\Word\Security\FileValidation" /v EnableOnLoad /t REG_DWORD /d 1 /f
        reg add "HKCU\Software\Microsoft\Office\16.0\PowerPoint\Security\FileValidation" /v EnableOnLoad /t REG_DWORD /d 1 /f
        reg add "HKCU\Software\Microsoft\Office\16.0\Outlook\Security" /v EnableUnsafeClientMailRules /t REG_DWORD /d 0 /f
        reg add "HKCU\Software\Microsoft\Office\16.0\Common\Security" /v DisableAllActiveX /t REG_DWORD /d 1 /f
    }
    if ($selectedSecurityOptions["General OS hardening"]) {
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v DisableHelpSticker /t REG_DWORD /d 1 /f
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\EdgeUI" /v DisableCharms /t REG_DWORD /d 1 /f
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v AllowTelemetry /t REG_DWORD /d 0 /f
        reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v EnableSmartScreen /t REG_DWORD /d 1 /f
    }
    if ($selectedSecurityOptions["Advanced Windows logging"]) {
        wevtutil sl Security /ca:Microsoft-Windows-Security-Auditing
        wevtutil sl System /ca:Microsoft-Windows-Kernel-General
        wevtutil sl Application /ca:Microsoft-Windows-Security-Auditing
    }
    if ($selectedSecurityOptions["Windows 10 Privacy Settings"]) {
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v Enabled /t REG_DWORD /d 0 /f
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v SuppressConsent /t REG_DWORD /d 1 /f
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SystemPaneSuggestionsEnabled /t REG_DWORD /d 0 /f
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v BingSearchEnabled /t REG_DWORD /d 0 /f
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\SearchSettings" /v CortanaEnabled /t REG_DWORD /d 0 /f
    }

    # Install selected software
    if ($selectedSoftwareOptions["Notepad++"]) {
        Invoke-WebRequest -Uri "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.1.9.2/npp.8.1.9.2.Installer.exe" -OutFile "C:\Temp\npp.Installer.exe"
        Start-Process "C:\Temp\npp.Installer.exe" -ArgumentList "/S" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["Google Chrome"]) {
        Invoke-WebRequest -Uri "https://dl.google.com/chrome/install/GoogleChromeStandaloneEnterprise64.msi" -OutFile "C:\Temp\GoogleChrome.msi"
        Start-Process "msiexec.exe" -ArgumentList "/i C:\Temp\GoogleChrome.msi /quiet /norestart" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["Mozilla Firefox"]) {
        Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" -OutFile "C:\Temp\FirefoxInstaller.exe"
        Start-Process "C:\Temp\FirefoxInstaller.exe" -ArgumentList "/S" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["Adobe Reader"]) {
        Invoke-WebRequest -Uri "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2000920062/AcroRdrDC1900820071_en_US.exe" -OutFile "C:\Temp\AdobeReaderInstaller.exe"
        Start-Process "C:\Temp\AdobeReaderInstaller.exe" -ArgumentList "/SALL" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["7-Zip"]) {
        Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z1900-x64.msi" -OutFile "C:\Temp\7zipInstaller.msi"
        Start-Process "msiexec.exe" -ArgumentList "/i C:\Temp\7zipInstaller.msi /quiet /norestart" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["WinRAR"]) {
        Invoke-WebRequest -Uri "https://www.rarlab.com/rar/winrar-x64-611.exe" -OutFile "C:\Temp\WinRARInstaller.exe"
        Start-Process "C:\Temp\WinRARInstaller.exe" -ArgumentList "/S" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["VLC Player"]) {
        Invoke-WebRequest -Uri "https://get.videolan.org/vlc/3.0.11.1/win64/vlc-3.0.11.1-win64.exe" -OutFile "C:\Temp\VLCInstaller.exe"
        Start-Process "C:\Temp\VLCInstaller.exe" -ArgumentList "/S" -NoNewWindow -Wait
    }

    # Confirm completion
    [System.Windows.MessageBox]::Show("Selected actions have been applied.", "Completion")
})

# Show the window
$window.ShowDialog() | Out-Null