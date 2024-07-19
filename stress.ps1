Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-Menu {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Advanced Stress Test Tool"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false

    # Créer un TableLayoutPanel pour une meilleure disposition
    $tableLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
    $tableLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
    $tableLayoutPanel.ColumnCount = 2
    $tableLayoutPanel.RowCount = 6
    $tableLayoutPanel.AutoSize = $true
    $form.Controls.Add($tableLayoutPanel)

    # Ajouter les éléments du menu
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Select the types of stress tests:"
    $label.AutoSize = $true
    $tableLayoutPanel.Controls.Add($label, 0, 0)
    $tableLayoutPanel.SetColumnSpan($label, 2)

    $categories = @{
        "CPU" = @("CPU", "CPU Math");
        "Memory" = @("Memory", "Memory Bandwidth");
        "Disk" = @("Disk Write", "Disk Read", "File System");
        "Network" = @("Network");
        "GPU" = @("GPU", "GPU Threads");
        "Video Playback" = @("Video Playback 1", "Video Playback 2", "Video Playback 3")
    }

    $checkboxes = @{}
    $rowIndex = 1
    foreach ($category in $categories.Keys) {
        $categoryLabel = New-Object System.Windows.Forms.Label
        $categoryLabel.Text = $category
        $categoryLabel.Font = New-Object System.Drawing.Font($categoryLabel.Font, [System.Drawing.FontStyle]::Bold)
        $categoryLabel.AutoSize = $true
        $tableLayoutPanel.Controls.Add($categoryLabel, 0, $rowIndex)
        
        $checkboxes[$category] = @()
        $colIndex = 0
        foreach ($test in $categories[$category]) {
            $checkbox = New-Object System.Windows.Forms.CheckBox
            $checkbox.Text = $test
            $checkbox.AutoSize = $true
            $tableLayoutPanel.Controls.Add($checkbox, $colIndex, $rowIndex + 1)
            $checkboxes[$category] += $checkbox
            $colIndex++
        }
        $rowIndex += 2
    }

    # Ajouter les boutons "Select All" et "Deselect All"
    $selectAllButton = New-Object System.Windows.Forms.Button
    $selectAllButton.Text = "Select All"
    $selectAllButton.AutoSize = $true
    $tableLayoutPanel.Controls.Add($selectAllButton, 0, $rowIndex)
    
    $deselectAllButton = New-Object System.Windows.Forms.Button
    $deselectAllButton.Text = "Deselect All"
    $deselectAllButton.AutoSize = $true
    $tableLayoutPanel.Controls.Add($deselectAllButton, 1, $rowIndex)
    
    $rowIndex++

    # Ajouter les éléments pour la durée et les boutons de démarrage
    $durationLabel = New-Object System.Windows.Forms.Label
    $durationLabel.Text = "Duration (seconds, 0 for infinite):"
    $durationLabel.AutoSize = $true
    $tableLayoutPanel.Controls.Add($durationLabel, 0, $rowIndex)

    $durationBox = New-Object System.Windows.Forms.TextBox
    $durationBox.Size = New-Object System.Drawing.Size(100, 20)
    $durationBox.Text = "60"
    $tableLayoutPanel.Controls.Add($durationBox, 1, $rowIndex)
    
    $rowIndex++
    
    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "Start Tests"
    $startButton.AutoSize = $true
    $tableLayoutPanel.Controls.Add($startButton, 0, $rowIndex)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.AutoSize = $true
    $tableLayoutPanel.Controls.Add($cancelButton, 1, $rowIndex)
    
    # Ajouter une barre de progression et une zone de résultats
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Dock = [System.Windows.Forms.DockStyle]::Top
    $progressBar.Height = 20
    $tableLayoutPanel.Controls.Add($progressBar, 0, $rowIndex + 1)
    $tableLayoutPanel.SetColumnSpan($progressBar, 2)

    $resultLabel = New-Object System.Windows.Forms.Label
    $resultLabel.Text = "Results:"
    $resultLabel.AutoSize = $true
    $tableLayoutPanel.Controls.Add($resultLabel, 0, $rowIndex + 2)
    $tableLayoutPanel.SetColumnSpan($resultLabel, 2)

    $resultBox = New-Object System.Windows.Forms.TextBox
    $resultBox.Multiline = $true
    $resultBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $resultBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $tableLayoutPanel.Controls.Add($resultBox, 0, $rowIndex + 3)
    $tableLayoutPanel.SetColumnSpan($resultBox, 2)

    # Gestion des clics sur les boutons
    $selectAllButton.Add_Click({
        foreach ($category in $checkboxes.Keys) {
            foreach ($checkbox in $checkboxes[$category]) {
                $checkbox.Checked = $true
            }
        }
    })

    $deselectAllButton.Add_Click({
        foreach ($category in $checkboxes.Keys) {
            foreach ($checkbox in $checkboxes[$category]) {
                $checkbox.Checked = $false
            }
        }
    })

    $startButton.Add_Click({
        $selectedTests = @()
        foreach ($category in $checkboxes.Keys) {
            $selectedTests += $checkboxes[$category] | Where-Object { $_.Checked } | ForEach-Object { $_.Text }
        }
        $duration = [int]$durationBox.Text
        if ($selectedTests -and $duration -ge 0) {
            $resultBox.Clear()
            $resultBox.AppendText("Starting tests...`n")
            $progressBar.Maximum = $selectedTests.Count
            $progressBar.Value = 0
            $cancelRequested = $false

            foreach ($test in $selectedTests) {
                if ($cancelRequested) { break }
                $results = Start-Test -Type $test -Duration $duration
                $resultBox.AppendText("`n" + $results)
                $progressBar.PerformStep()
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one test and enter a valid duration.")
        }
    })

    $cancelButton.Add_Click({
        $cancelRequested = $true
        $resultBox.AppendText("Tests cancelled.`n")
    })

    $form.ShowDialog()
}

function Start-CPUTest {
    param (
        [int]$Duration = 60,
        [int]$Threads = [Environment]::ProcessorCount,
        [switch]$LogPerformance
    )

    $log = "CPU Stress Test Results:`n"
    $startTime = [DateTime]::Now
    $endTime = if ($Duration -eq 0) { [DateTime]::MaxValue } else { $startTime.AddSeconds($Duration) }

    $cpuThreads = [System.Collections.ArrayList]::new()

    for ($i = 0; $i -lt $Threads; $i++) {
        $cpuThreads.Add([powershell]::Create().AddScript({
            param ($endTime)
            while ([DateTime]::Now -lt $endTime) {
                [Math]::Sqrt(12345) > $null
            }
        }).AddArgument($endTime).BeginInvoke())
    }

    if ($LogPerformance) {
        $cpuCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
        $startCpuUsage = $cpuCounter.NextValue()
        Start-Sleep -Seconds 1
        $log += "Performance Log:`n"
    }

    Start-Sleep -Seconds $Duration

    $cpuThreads | ForEach-Object {
        $_.EndInvoke($_)
    }

    if ($LogPerformance) {
        $endCpuUsage = $cpuCounter.NextValue()
        $log += "Initial CPU Usage: $startCpuUsage%`n"
        $log += "Final CPU Usage: $endCpuUsage%`n"
    }

    $log += "CPU Stress Test Completed.`n"

    return $log
}

function Start-MemoryTest {
    param (
        [int]$Duration = 60,
        [int]$MemoryMB = 1024
    )
    $log = "Memory Stress Test Results:`n"
    try {
        $array = New-Object byte[] ($MemoryMB * 1MB)
        [void]$array.SetValue(0, 0)
        if ($Duration -gt 0) { Start-Sleep -Seconds $Duration } else { while ($true) { Start-Sleep -Seconds 1 } }
        $array = $null
        [System.GC]::Collect()
        $log += "Memory Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-DiskWriteTest {
    param (
        [int]$Duration = 60,
        [string]$FilePath = "C:\Temp\stress_test_write.tmp"
    )
    $log = "Disk Write Stress Test Results:`n"
    try {
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { [DateTime]::Now.AddSeconds($Duration) }
        while ([DateTime]::Now -lt $end) {
            $fileContent = New-Object byte[] (10MB)
            [System.IO.File]::WriteAllBytes($FilePath, $fileContent)
            Remove-Item -Path $FilePath
        }
        $log += "Disk Write Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-DiskReadTest {
    param (
        [int]$Duration = 60,
        [string]$FilePath = "C:\Temp\stress_test_read.tmp"
    )
    $log = "Disk Read Stress Test Results:`n"
    try {
        $fileContent = New-Object byte[] (10MB)
        [System.IO.File]::WriteAllBytes($FilePath, $fileContent)
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { [DateTime]::Now.AddSeconds($Duration) }
        while ([DateTime]::Now -lt $end) {
            [System.IO.File]::ReadAllBytes($FilePath)
        }
        Remove-Item -Path $FilePath
        $log += "Disk Read Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-NetworkTest {
    param (
        [int]$Duration = 60,
        [string]$Url = "http://speedtest.tele2.net/10MB.zip"
    )
    $log = "Network Stress Test Results:`n"
    try {
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { [DateTime]::Now.AddSeconds($Duration) }
        while ([DateTime]::Now -lt $end) {
            Invoke-WebRequest -Uri $Url -OutFile "C:\Temp\network_test.tmp"
            Remove-Item -Path "C:\Temp\network_test.tmp"
        }
        $log += "Network Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-GPUTest {
    param (
        [int]$Duration = 60
    )
    $log = "GPU Stress Test Results:`n"
    try {
        $start = Get-Date
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { $start.AddSeconds($Duration) }
        while ((Get-Date) -lt $end) {
            Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;
            public class GpuStress
            {
                [DllImport("kernel32.dll", SetLastError = true)]
                public static extern IntPtr LoadLibrary(string lpFileName);

                [DllImport("nvapi.dll", SetLastError = true)]
                public static extern IntPtr NvAPI_Initialize();

                public static void Stress()
                {
                    IntPtr nvapi = LoadLibrary("nvapi.dll");
                    if (nvapi != IntPtr.Zero)
                    {
                        NvAPI_Initialize();
                        for (int i = 0; i < 1000000; i++)
                        {
                            Math.Sqrt(12345);
                        }
                    }
                }
            }
"@
            [GpuStress]::Stress()
        }
        $log += "GPU Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-CPUMathTest {
    param (
        [int]$Duration = 60
    )
    $log = "CPU Math Stress Test Results:`n"
    try {
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { [DateTime]::Now.AddSeconds($Duration) }
        while ([DateTime]::Now -lt $end) {
            for ($i = 0; $i -lt 1000000; $i++) {
                [Math]::Pow($i, 2) > $null
            }
        }
        $log += "CPU Math Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-MemoryBandwidthTest {
    param (
        [int]$Duration = 60
    )
    $log = "Memory Bandwidth Stress Test Results:`n"
    try {
        $array = New-Object byte[] (1024 * 1024 * 512) # 512MB
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { [DateTime]::Now.AddSeconds($Duration) }
        while ([DateTime]::Now -lt $end) {
            for ($i = 0; $i -lt $array.Length; $i++) {
                $array[$i] = 1
            }
        }
        $log += "Memory Bandwidth Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-GPUThreadTest {
    param (
        [int]$Duration = 60
    )
    $log = "GPU Thread Stress Test Results:`n"
    try {
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { [DateTime]::Now.AddSeconds($Duration) }
        while ([DateTime]::Now -lt $end) {
            Add-Type -TypeDefinition @"
            using System;
            using System.Threading;
            public class GpuThreadStress
            {
                public static void Stress()
                {
                    for (int i = 0; i < 100; i++)
                    {
                        new Thread(() =>
                        {
                            for (int j = 0; j < 1000000; j++)
                            {
                                Math.Sqrt(12345);
                            }
                        }).Start();
                    }
                }
            }
"@
            [GpuThreadStress]::Stress()
        }
        $log += "GPU Thread Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-FileSystemTest {
    param (
        [int]$Duration = 60
    )
    $log = "File System Stress Test Results:`n"
    try {
        $end = if ($Duration -eq 0) { [DateTime]::MaxValue } else { [DateTime]::Now.AddSeconds($Duration) }
        $testDir = "C:\Temp\FileSystemTest"
        if (-not (Test-Path -Path $testDir)) {
            New-Item -ItemType Directory -Path $testDir
        }
        while ([DateTime]::Now -lt $end) {
            $fileName = [System.IO.Path]::Combine($testDir, [System.IO.Path]::GetRandomFileName())
            $fileContent = New-Object byte[] (1MB)
            [System.IO.File]::WriteAllBytes($fileName, $fileContent)
            [System.IO.File]::ReadAllBytes($fileName)
            Remove-Item -Path $fileName
        }
        Remove-Item -Path $testDir -Recurse
        $log += "File System Stress Test Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-VideoPlaybackTest1 {
    param (
        [int]$Duration = 60,
        [string]$Url = "https://www.w3schools.com/html/mov_bbb.mp4"
    )
    $log = "Video Playback Test 1 Results:`n"
    try {
        Start-Process $Url
        if ($Duration -gt 0) { Start-Sleep -Seconds $Duration } else { while ($true) { Start-Sleep -Seconds 1 } }
        $log += "Video Playback Test 1 Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-VideoPlaybackTest2 {
    param (
        [int]$Duration = 60,
        [string]$Url = "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4"
    )
    $log = "Video Playback Test 2 Results:`n"
    try {
        Start-Process $Url
        if ($Duration -gt 0) { Start-Sleep -Seconds $Duration } else { while ($true) { Start-Sleep -Seconds 1 } }
        $log += "Video Playback Test 2 Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-VideoPlaybackTest3 {
    param (
        [int]$Duration = 60,
        [string]$Url = "https://sample-videos.com/video123/mp4/480/asdasdas.mp4"
    )
    $log = "Video Playback Test 3 Results:`n"
    try {
        Start-Process $Url
        if ($Duration -gt 0) { Start-Sleep -Seconds $Duration } else { while ($true) { Start-Sleep -Seconds 1 } }
        $log += "Video Playback Test 3 Completed.`n"
    } catch {
        $log += "Error: $_`n"
    }
    return $log
}

function Start-Test {
    param (
        [string]$Type,
        [int]$Duration
    )
    $results = ""
    switch ($Type) {
        "CPU" { $results = Start-CPUTest -Duration $Duration -Threads 8 -LogPerformance }
        "Memory" { $results = Start-MemoryTest -Duration $Duration -MemoryMB 2048 }
        "Disk Write" { $results = Start-DiskWriteTest -Duration $Duration }
        "Disk Read" { $results = Start-DiskReadTest -Duration $Duration }
        "Network" { $results = Start-NetworkTest -Duration $Duration }
        "GPU" { $results = Start-GPUTest -Duration $Duration }
        "CPU Math" { $results = Start-CPUMathTest -Duration $Duration }
        "Memory Bandwidth" { $results = Start-MemoryBandwidthTest -Duration $Duration }
        "GPU Threads" { $results = Start-GPUThreadTest -Duration $Duration }
        "File System" { $results = Start-FileSystemTest -Duration $Duration }
        "Video Playback 1" { $results = Start-VideoPlaybackTest1 -Duration $Duration }
        "Video Playback 2" { $results = Start-VideoPlaybackTest2 -Duration $Duration }
        "Video Playback 3" { $results = Start-VideoPlaybackTest3 -Duration $Duration }
        default { $results = "Invalid test type selected." }
    }
    return $results
}

Show-Menu
