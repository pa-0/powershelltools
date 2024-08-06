# Fonction pour obtenir les éléments de démarrage via le registre
function Get-StartupItemsFromRegistry {
    $results = @()
    $paths = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
    )
    
    foreach ($path in $paths) {
        $items = Get-ItemProperty -Path $path | Select-Object PSChildName, *
        $items | ForEach-Object {
            $results += [PSCustomObject]@{
                Source = "Démarrage (registre)"
                Path = $path
                Data = $_ | ConvertTo-Html -Fragment
            }
        }
    }
    
    return $results
}

# Fonction pour obtenir les éléments de démarrage via les dossiers de démarrage
function Get-StartupItemsFromFolders {
    $results = @()
    $folders = @(
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp",
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    )
    
    foreach ($folder in $folders) {
        $items = Get-ChildItem -Path $folder | Select-Object Name, @{Name="FullPath";Expression={$_.FullName}}
        $items | ForEach-Object {
            $results += [PSCustomObject]@{
                Source = "Démarrage (dossier)"
                Path = $folder
                Data = $_ | ConvertTo-Html -Fragment
            }
        }
    }
    
    return $results
}

# Fonction pour obtenir les tâches planifiées
function Get-ScheduledTasks {
    $results = @()
    $tasks = Get-ScheduledTask | Select-Object TaskName, TaskPath, @{Name="LastRunTime";Expression={(Get-ScheduledTaskInfo -TaskName $_.TaskName).LastRunTime}}
    $tasks | ForEach-Object {
        $results += [PSCustomObject]@{
            Source = "Tâches planifiées"
            Path = ""
            Data = $_ | ConvertTo-Html -Fragment
        }
    }
    
    return $results
}

# Fonction pour obtenir les processus en cours
function Get-RunningProcesses {
    $results = @()
    $processes = Get-Process | Select-Object Name, Id, @{Name="Path";Expression={(Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").ExecutablePath}}
    $processes | ForEach-Object {
        $results += [PSCustomObject]@{
            Source = "Processus en cours"
            Path = ""
            Data = $_ | ConvertTo-Html -Fragment
        }
    }
    
    return $results
}

# Génération du rapport HTML avec horodatage
function Generate-Report {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss")
    $reportFile = "C:\Path\To\Report_$timestamp.html"
    
    $header = @"
<html>
<head>
    <title>Rapport d'analyse</title>
    <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; margin: 0; padding: 20px; background-color: #f4f4f4; }
        h1, h2 { color: #333; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; border: 1px solid #ddd; }
        th { background: #333; color: #fff; }
        tr:nth-child(even) { background: #f9f9f9; }
        .container { max-width: 900px; margin: auto; background: #fff; padding: 20px; border-radius: 5px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
    </style>
</head>
<body>
    <div class="container">
        <h1>Rapport d'analyse de démarrage et des processus</h1>
"@

    $footer = @"
    </div>
</body>
</html>
"@

    $content = @()
    $content += $header
    
    $sections = @(Get-StartupItemsFromRegistry, Get-StartupItemsFromFolders, Get-ScheduledTasks, Get-RunningProcesses)
    
    foreach ($section in $sections) {
        foreach ($item in $section) {
            $content += "<h2>$($item.Source)</h2>"
            if ($item.Path) {
                $content += "<p><strong>Chemin:</strong> $($item.Path)</p>"
            }
            $content += $item.Data
        }
    }
    
    $content += $footer
    
    $content | Out-File -FilePath $reportFile -Encoding utf8
}

# Exécution des fonctions et génération du rapport
Generate-Report