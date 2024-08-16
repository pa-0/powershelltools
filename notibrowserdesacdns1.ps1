# Activer le mode Sandbox de Windows (disponible sur Windows 10 Pro/Enterprise)
function Enable-WindowsSandbox {
    Write-Host "Activation du mode Sandbox de Windows..."
    Enable-WindowsOptionalFeature -FeatureName "Containers-DisposableClientVM" -Online -NoRestart
    Write-Host "Mode Sandbox de Windows activé."
}

# Forcer l'utilisation du DNS sécurisé 1.1.1.1 sur l'interface réseau principale
function Set-DNSCloudflare {
    Write-Host "Configuration du DNS Cloudflare 1.1.1.1 sur l'interface réseau principale..."
    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1
    if ($adapter) {
        Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("1.1.1.1", "1.0.0.1")
        Write-Host "DNS configuré sur 1.1.1.1 et 1.0.0.1 pour l'interface $($adapter.Name)."
    } else {
        Write-Host "Aucune interface réseau active n'a été trouvée."
    }
}

# Désactiver les notifications pour Google Chrome
function Disable-ChromeNotifications {
    $chromeProfilePath = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default"
    
    if (Test-Path $chromeProfilePath) {
        Write-Host "Désactivation des notifications dans Google Chrome..."
        $preferencesPath = "$chromeProfilePath\Preferences"
        if (Test-Path $preferencesPath) {
            $json = Get-Content $preferencesPath -Raw | ConvertFrom-Json
            $json.profile.default_content_setting_values.notifications = 2
            $json | ConvertTo-Json -Compress | Set-Content $preferencesPath
            Write-Host "Les notifications ont été désactivées dans Google Chrome."
        } else {
            Write-Host "Le fichier de préférences de Google Chrome est introuvable."
        }
    } else {
        Write-Host "Google Chrome n'est pas installé ou le profil est introuvable."
    }
}

# Désactiver les notifications pour Microsoft Edge
function Disable-EdgeNotifications {
    $edgeProfilePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default"
    
    if (Test-Path $edgeProfilePath) {
        Write-Host "Désactivation des notifications dans Microsoft Edge..."
        $preferencesPath = "$edgeProfilePath\Preferences"
        if (Test-Path $preferencesPath) {
            $json = Get-Content $preferencesPath -Raw | ConvertFrom-Json
            $json.profile.default_content_setting_values.notifications = 2
            $json | ConvertTo-Json -Compress | Set-Content $preferencesPath
            Write-Host "Les notifications ont été désactivées dans Microsoft Edge."
        } else {
            Write-Host "Le fichier de préférences de Microsoft Edge est introuvable."
        }
    } else {
        Write-Host "Microsoft Edge n'est pas installé ou le profil est introuvable."
    }
}

# Désactiver les notifications pour Mozilla Firefox
function Disable-FirefoxNotifications {
    $firefoxProfilePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
    
    if (Test-Path $firefoxProfilePath) {
        $profiles = Get-ChildItem -Path $firefoxProfilePath -Directory
        foreach ($profile in $profiles) {
            Write-Host "Désactivation des notifications dans Mozilla Firefox pour le profil $($profile.Name)..."
            $prefsJsPath = "$($profile.FullName)\prefs.js"
            if (Test-Path $prefsJsPath) {
                $prefsJs = Get-Content $prefsJsPath
                if ($prefsJs -notcontains 'user_pref("permissions.default.desktop-notification", 2);') {
                    Add-Content $prefsJsPath 'user_pref("permissions.default.desktop-notification", 2);'
                    Write-Host "Les notifications ont été désactivées dans Mozilla Firefox pour le profil $($profile.Name)."
                } else {
                    Write-Host "Les notifications sont déjà désactivées pour le profil $($profile.Name)."
                }
            } else {
                Write-Host "Le fichier prefs.js de Mozilla Firefox est introuvable pour le profil $($profile.Name)."
            }
        }
    } else {
        Write-Host "Mozilla Firefox n'est pas installé ou le profil est introuvable."
    }
}

# Exécution des fonctions
Enable-WindowsSandbox
Set-DNSCloudflare
Disable-ChromeNotifications
Disable-EdgeNotifications
Disable-FirefoxNotifications

Write-Host "Toutes les configurations de sécurité ont été appliquées."