Add-Type -AssemblyName PresentationFramework

# Window
$window = New-Object System.Windows.Window
$window.Title = "System Configuration"
$window.Width = 600
$window.Height = 800
$window.WindowStartupLocation = "CenterScreen"

# StackPanel
$stackPanel = New-Object System.Windows.Controls.StackPanel
$stackPanel.Orientation = "Vertical"
$stackPanel.HorizontalAlignment = "Center"

# Create a function to add checkboxes
function Add-Checkbox {
    param (
        [string]$labelText,
        [string]$tag,
        [ref]$checkboxDict
    )
    $checkbox = New-Object System.Windows.Controls.CheckBox
    $checkbox.Content = $labelText
    $checkbox.Tag = $tag
    $checkbox.Add_Checked({$checkboxDict.Value[$_this.Tag] = $true})
    $checkbox.Add_Unchecked({$checkboxDict.Value[$_this.Tag] = $false})
    $checkboxDict.Value[$tag] = $false
    $stackPanel.Children.Add($checkbox)
}

# Dictionaries to hold the state of checkboxes
$selectedSecurityOptions = @{}
$selectedSoftwareOptions = @{}

# Add main categories and their sub-checkboxes
$mainCategories = @(
    @{Label = "Security Settings"; SubItems = @("Enable BitLocker", "Enable Controlled Folder Access", "Enable Exploit Guard", "Harden Office", "General OS hardening", "Advanced Windows logging", "Windows 10 Privacy Settings")},
    @{Label = "Software Installation"; SubItems = @("Notepad++", "Google Chrome", "Mozilla Firefox", "Adobe Reader", "7-Zip", "WinRAR", "VLC Player")}
)

foreach ($category in $mainCategories) {
    # Main category checkbox
    $mainCheckbox = New-Object System.Windows.Controls.CheckBox
    $mainCheckbox.Content = $category.Label
    $mainCheckbox.FontWeight = "Bold"
    $stackPanel.Children.Add($mainCheckbox)
    
    foreach ($item in $category.SubItems) {
        $subCheckbox = New-Object System.Windows.Controls.CheckBox
        $subCheckbox.Content = "    " + $item
        $subCheckbox.Tag = $item
        $subCheckbox.Add_Checked({
            $selectedSecurityOptions[$_this.Tag] = $true
            if ($category.Label -eq "Software Installation") {
                $selectedSoftwareOptions[$_this.Tag] = $true
            }
        })
        $subCheckbox.Add_Unchecked({
            $selectedSecurityOptions[$_this.Tag] = $false
            if ($category.Label -eq "Software Installation") {
                $selectedSoftwareOptions[$_this.Tag] = $false
            }
        })
        $selectedSecurityOptions[$item] = $false
        if ($category.Label -eq "Software Installation") {
            $selectedSoftwareOptions[$item] = $false
        }
        $stackPanel.Children.Add($subCheckbox)
        
        # Check/uncheck sub-checkboxes based on main checkbox state
        $mainCheckbox.Add_Checked({
            $subCheckbox.IsChecked = $true
        })
        $mainCheckbox.Add_Unchecked({
            $subCheckbox.IsChecked = $false
        })
    }
}

# Select All and Clear All buttons
$selectAllButton = New-Object System.Windows.Controls.Button
$selectAllButton.Content = "Select All"
$selectAllButton.Add_Click({
    foreach ($child in $stackPanel.Children) {
        if ($child -is [System.Windows.Controls.CheckBox]) {
            $child.IsChecked = $true
        }
    }
})
$stackPanel.Children.Add($selectAllButton)

$clearAllButton = New-Object System.Windows.Controls.Button
$clearAllButton.Content = "Clear All"
$clearAllButton.Add_Click({
    foreach ($child in $stackPanel.Children) {
        if ($child -is [System.Windows.Controls.CheckBox]) {
            $child.IsChecked = $false
        }
    }
})
$stackPanel.Children.Add($clearAllButton)

# Battery Report button
$batteryReportButton = New-Object System.Windows.Controls.Button
$batteryReportButton.Content = "Generate Battery Report"
$batteryReportButton.Add_Click({
    powercfg /batteryreport /output "C:\BatteryReport.html"
    [System.Windows.MessageBox]::Show("Battery report generated at C:\BatteryReport.html", "Battery Report")
})
$stackPanel.Children.Add($batteryReportButton)

# Submit button
$submitButton = New-Object System.Windows.Controls.Button
$submitButton.Content = "Submit"
$submitButton.Add_Click({
    # Apply selected security options
    if ($selectedSecurityOptions["Enable BitLocker"]) {
        Start-Process -FilePath "powershell.exe" -ArgumentList "Enable-BitLocker -MountPoint 'C:' -PasswordProtector" -NoNewWindow -Wait
    }
    if ($selectedSecurityOptions["Enable Controlled Folder Access"]) {
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
        Start-Process "msiexec.exe" -ArgumentList "/i C:\Temp\GoogleChrome.msi /quiet" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["Mozilla Firefox"]) {
        Invoke-WebRequest -Uri "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=en-US" -OutFile "C:\Temp\FirefoxInstaller.exe"
        Start-Process "C:\Temp\FirefoxInstaller.exe" -ArgumentList "/S" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["Adobe Reader"]) {
        Invoke-WebRequest -Uri "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2100620048/AcroRdrDC2100620048_en_US.exe" -OutFile "C:\Temp\AcroRdrDC.exe"
        Start-Process "C:\Temp\AcroRdrDC.exe" -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["7-Zip"]) {
        Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z1900-x64.msi" -OutFile "C:\Temp\7zip.msi"
        Start-Process "msiexec.exe" -ArgumentList "/i C:\Temp\7zip.msi /quiet" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["WinRAR"]) {
        Invoke-WebRequest -Uri "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-602.exe" -OutFile "C:\Temp\WinRAR.exe"
        Start-Process "C:\Temp\WinRAR.exe" -ArgumentList "/S" -NoNewWindow -Wait
    }
    if ($selectedSoftwareOptions["VLC Player"]) {
        Invoke-WebRequest -Uri "https://get.videolan.org/vlc/3.0.11.1/win64/vlc-3.0.11.1-win64.exe" -OutFile "C:\Temp\vlc.exe"
        Start-Process "C:\Temp\vlc.exe" -ArgumentList "/S" -NoNewWindow -Wait
    }

    [System.Windows.MessageBox]::Show("Configuration applied successfully", "Status")
})
$stackPanel.Children.Add($submitButton)

# ScrollViewer to make the window scrollable
$scrollViewer = New-Object System.Windows.Controls.ScrollViewer
$scrollViewer.VerticalScrollBarVisibility = "Auto"
$scrollViewer.Content = $stackPanel

# Set the content of the window
$window.Content = $scrollViewer

# Show the window
$window.ShowDialog()