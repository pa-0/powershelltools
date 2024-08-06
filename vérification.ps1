# Obtenir les éléments de démarrage via le registre
function Get-StartupItemsFromRegistry {
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    )
    
    foreach ($path in $paths) {
        Write-Output "Démarrage (registre) : $path"
        Get-ItemProperty -Path $path | Select-Object PSChildName, * | Format-Table -AutoSize
        Write-Output ""
    }
}

# Obtenir les éléments de démarrage via les dossiers de démarrage
function Get-StartupItemsFromFolders {
    $folders = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    
    foreach ($folder in $folders) {
        Write-Output "Démarrage (dossier) : $folder"
        Get-ChildItem -Path $folder | Select-Object Name, @{Name="FullPath";Expression={$_.FullName}} | Format-Table -AutoSize
        Write-Output ""
    }
}

# Obtenir les tâches planifiées
function Get-ScheduledTasks {
    Write-Output "Tâches planifiées :"
    Get-ScheduledTask | Select-Object TaskName, TaskPath, @{Name="Command";Expression={(Get-ScheduledTaskInfo -TaskName $_.TaskName).LastRunTime}} | Format-Table -AutoSize
    Write-Output ""
}

# Obtenir les processus en cours
function Get-RunningProcesses {
    Write-Output "Processus en cours :"
    Get-Process | Select-Object Name, Id, @{Name="Path";Expression={(Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").ExecutablePath}} | Format-Table -AutoSize
}

# Obtenir les services en cours d'exécution
function Get-RunningServices {
    Write-Output "Services en cours d'exécution :"
    Get-Service | Where-Object { $_.Status -eq 'Running' } | Select-Object Name, DisplayName, Status | Format-Table -AutoSize
}

# Obtenir les connexions réseau actives
function Get-NetworkConnections {
    Write-Output "Connexions réseau actives :"
    Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | Format-Table -AutoSize
}

# Obtenir les utilisateurs connectés
function Get-LoggedInUsers {
    Write-Output "Utilisateurs connectés :"
    query user | Format-Table -AutoSize
}

# Vérifier les modifications du mode sans échec
function Check-SafeMode {
    Write-Output "Vérification des modifications du mode sans échec :"
    Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SafeBoot" | Format-Table -AutoSize
}

# Obtenir les modules chargés par les processus
function Get-ProcessModules {
    Write-Output "Modules chargés par les processus :"
    Get-Process | ForEach-Object {
        $modules = $_.Modules | Select-Object ModuleName, FileName
        Write-Output "Processus : $($_.Name) (ID: $($_.Id))"
        $modules | Format-Table -AutoSize
        Write-Output ""
    }
}

# Exécution des fonctions
Get-StartupItemsFromRegistry
Get-StartupItemsFromFolders
Get-ScheduledTasks
Get-RunningProcesses
Get-RunningServices
Get-NetworkConnections
Get-LoggedInUsers
Check-SafeMode
Get-ProcessModules