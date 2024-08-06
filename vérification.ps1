function Generate-Report {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd_HH-mm-ss");
    $reportFile = "C:\Path\To\Report_$timestamp.html";
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
"@;
    $footer = @"
    </div>
</body>
</html>
"@;
    $content = @();
    $content += $header;

    $sections = @(
        @{ Name = "Démarrage (registre)"; Items = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | Select-Object PSChildName, * },
        @{ Name = "Démarrage (dossier)"; Items = Get-ChildItem -Path "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup" | Select-Object Name, @{Name="FullPath";Expression={$_.FullName}} },
        @{ Name = "Tâches planifiées"; Items = Get-ScheduledTask | Select-Object TaskName, TaskPath, @{Name="LastRunTime";Expression={(Get-ScheduledTaskInfo -TaskName $_.TaskName).LastRunTime}} },
        @{ Name = "Processus en cours"; Items = Get-Process | Select-Object Name, Id, @{Name="Path";Expression={(Get-WmiObject Win32_Process -Filter "ProcessId=$($_.Id)").ExecutablePath}} }
    );

    foreach ($section in $sections) {
        $content += "<h2>$($section.Name)</h2>";
        if ($section.Name -eq "Démarrage (registre)" -or $section.Name -eq "Démarrage (dossier)") {
            foreach ($item in $section.Items) {
                $content += "<table><tr><th>Nom</th><th>Valeur</th></tr>";
                $item.PSObject.Properties | Where-Object { $_.Name -ne "PSChildName" } | ForEach-Object {
                    $content += "<tr><td>$($_.Name)</td><td>$($_.Value)</td></tr>";
                }
                $content += "</table>";
            }
        } elseif ($section.Name -eq "Tâches planifiées") {
            $content += "<table><tr><th>Nom</th><th>Chemin</th><th>Dernière exécution</th></tr>";
            foreach ($item in $section.Items) {
                $content += "<tr><td>$($item.TaskName)</td><td>$($item.TaskPath)</td><td>$($item.LastRunTime)</td></tr>";
            }
            $content += "</table>";
        } elseif ($section.Name -eq "Processus en cours") {
            $content += "<table><tr><th>Nom</th><th>ID</th><th>Chemin</th></tr>";
            foreach ($item in $section.Items) {
                $content += "<tr><td>$($item.Name)</td><td>$($item.Id)</td><td>$($item.Path)</td></tr>";
            }
            $content += "</table>";
        }
    }

    $content += $footer;
    $content | Out-File -FilePath $reportFile -Encoding utf8;
}

# Exécution de la fonction pour générer le rapport
Generate-Report