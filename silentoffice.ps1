# Définir les URLs et les chemins de destination
$officeDeploymentToolUrl = "https://aka.ms/ODT"
$downloadPath = "$env:TEMP\OfficeDeploymentTool.exe"
$installFolder = "$env:ProgramFiles\OfficeDeploymentTool"

# Créer le dossier d'installation s'il n'existe pas
if (-not (Test-Path $installFolder)) {
    New-Item -ItemType Directory -Path $installFolder -Force
}

# Télécharger l'outil de déploiement d'Office
Write-Host "Downloading Office Deployment Tool..."
Invoke-WebRequest -Uri $officeDeploymentToolUrl -OutFile $downloadPath

# Exécuter l'outil de déploiement pour extraire les fichiers
Write-Host "Extracting Office Deployment Tool..."
Start-Process -FilePath $downloadPath -ArgumentList "/quiet /extract:$installFolder" -Wait

# Définir le chemin du fichier setup.exe
$setupExePath = "$installFolder\setup.exe"

# Fonction pour vérifier si un processus est en cours d'exécution
function Wait-ProcessByName {
    param (
        [string]$ProcessName
    )

    while (Get-Process -Name $ProcessName -ErrorAction SilentlyContinue) {
        Start-Sleep -Seconds 5
    }
}

# Exécuter l'installation silencieuse
if (Test-Path $setupExePath) {
    Write-Host "Starting silent installation of Microsoft Office 365..."
    try {
        Start-Process -FilePath $setupExePath -ArgumentList "/configure $installFolder\configuration.xml" -Wait

        # Attendre la fin de l'installation
        Wait-ProcessByName -ProcessName "setup"

        Write-Host "Microsoft Office 365 installation completed successfully."
    } catch {
        Write-Error "An error occurred during the installation: $_"
    }
} else {
    Write-Error "The Office Deployment Tool setup.exe was not found."
}

# Nettoyage
Write-Host "Cleaning up..."
Remove-Item -Path $downloadPath -Force