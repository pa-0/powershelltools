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

# Exécution des fonctions
Get-StartupItemsFromRegistry
Get-StartupItemsFromFolders
Get-ScheduledTasks
Get-RunningProcesses