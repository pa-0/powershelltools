Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-Menu {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Advanced Stress Test Tool"
    $form.Size = New-Object System.Drawing.Size(600, 700)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = 'FixedDialog'
    $form.MaximizeBox = $false

    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Select the types of stress tests:"
    $label.Location = New-Object System.Drawing.Point(10, 10)
    $label.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($label)

    $checkboxes = @()
    $tests = @("CPU", "Memory", "Disk Write", "Disk Read", "Network", "GPU", "CPU Math", "Memory Bandwidth", "GPU Threads", "File System", "Video Playback")
    $yPosition = 40
    foreach ($test in $tests) {
        $checkbox = New-Object System.Windows.Forms.CheckBox
        $checkbox.Text = $test
        $checkbox.Location = New-Object System.Drawing.Point(10, $yPosition)
        $checkbox.Size = New-Object System.Drawing.Size(200, 20)
        $form.Controls.Add($checkbox)
        $checkboxes += $checkbox
        $yPosition += 25
    }

    $selectAllButton = New-Object System.Windows.Forms.Button
    $selectAllButton.Text = "Select All"
    $selectAllButton.Location = New-Object System.Drawing.Point(220, 40)
    $selectAllButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($selectAllButton)

    $deselectAllButton = New-Object System.Windows.Forms.Button
    $deselectAllButton.Text = "Deselect All"
    $deselectAllButton.Location = New-Object System.Drawing.Point(330, 40)
    $deselectAllButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($deselectAllButton)

    $durationLabel = New-Object System.Windows.Forms.Label
    $durationLabel.Text = "Duration (seconds):"
    $durationLabel.Location = New-Object System.Drawing.Point(10, 300)
    $durationLabel.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($durationLabel)

    $durationBox = New-Object System.Windows.Forms.TextBox
    $durationBox.Location = New-Object System.Drawing.Point(10, 330)
    $durationBox.Size = New-Object System.Drawing.Size(200, 20)
    $durationBox.Text = "60"
    $form.Controls.Add($durationBox)

    $startButton = New-Object System.Windows.Forms.Button
    $startButton.Text = "Start Tests"
    $startButton.Location = New-Object System.Drawing.Point(10, 360)
    $startButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($startButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.Location = New-Object System.Drawing.Point(120, 360)
    $cancelButton.Size = New-Object System.Drawing.Size(100, 30)
    $form.Controls.Add($cancelButton)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(10, 400)
    $progressBar.Size = New-Object System.Drawing.Size(560, 20)
    $form.Controls.Add($progressBar)

    $resultLabel = New-Object System.Windows.Forms.Label
    $resultLabel.Text = "Results:"
    $resultLabel.Location = New-Object System.Drawing.Point(10, 430)
    $resultLabel.Size = New-Object System.Drawing.Size(560, 20)
    $form.Controls.Add($resultLabel)

    $resultBox = New-Object System.Windows.Forms.TextBox
    $resultBox.Location = New-Object System.Drawing.Point(10, 460)
    $resultBox.Size = New-Object System.Drawing.Size(560, 200)
    $resultBox.Multiline = $true
    $resultBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
    $form.Controls.Add($resultBox)

    $selectAllButton.Add_Click({
        foreach ($checkbox in $checkboxes) {
            $checkbox.Checked = $true
        }
    })

    $deselectAllButton.Add_Click({
        foreach ($checkbox in $checkboxes) {
            $checkbox.Checked = $false
        }
    })

    $startButton.Add_Click({
        $selectedTests = $checkboxes | Where-Object { $_.Checked } | ForEach-Object { $_.Text }
        $duration = [int]$durationBox.Text
        if ($selectedTests -and $duration -gt 0) {
            $resultBox.Text = "Starting tests for $duration seconds..."
            $progressBar.Maximum = $selectedTests.Count
            $progressBar.Value = 0
            foreach ($test in $selectedTests) {
                $results = Start-Test -Type $test -Duration $duration
                $resultBox.Text += "`n" + $results
                $progressBar.PerformStep()
            }
        } else {
            [System.Windows.Forms.MessageBox]::Show("Please select at least one test and enter a valid duration.")
        }
    })

    $cancelButton.Add_Click({
        $form.Close()
    })

    $form.Topmost = $true
    $form.Add_Shown({$form.Activate()})
    [void]$form.ShowDialog()
}

function Start-CPUTest {
    param (
        [int]$Duration = 60
    )
    $log = "CPU Stress Test Results:`n"
    $scriptBlock = {
        $end = [DateTime]::Now.AddSeconds($Duration)
        while ([DateTime]::Now -lt $end) {
            [Math]::Sqrt(12345) > $null
        }
    }
    $jobs = @()
    for ($i = 0; $i -lt [Environment]::ProcessorCount; $i++) {
        $jobs += Start-Job -ScriptBlock $scriptBlock
    }
    Start-Sleep -Seconds $Duration
    $errors = $jobs | ForEach-Object { Receive-Job -Job $_ -ErrorAction SilentlyContinue }
    $jobs | Remove-Job
    $log += "Errors: $errors`n"
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
        Start-Sleep -Seconds $Duration
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
        $end = [DateTime]::Now.AddSeconds($Duration)
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
        $end = [DateTime]::Now.AddSeconds($Duration)
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
        $end = [DateTime]::Now.AddSeconds($Duration)
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
        $end = $start.AddSeconds($Duration)
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
        $end = [DateTime]::Now.AddSeconds($Duration)
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
        $end = [DateTime]::Now.AddSeconds($Duration)
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
        $end = [DateTime]::Now.AddSeconds($Duration)
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
        $end = [DateTime]::Now.AddSeconds($Duration)
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

function Start-VideoPlaybackTest {
    param (
        [int]$Duration = 60,
        [string]$Url = "https://www.w3schools.com/html/mov_bbb.mp4"
    )
    $log = "Video Playback Test Results:`n"
    try {
        Start-Process $Url
        Start-Sleep -Seconds $Duration
        $log += "Video Playback Test Completed.`n"
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
        "CPU" { $results = Start-CPUTest -Duration $Duration }
        "Memory" { $results = Start-MemoryTest -Duration $Duration -MemoryMB 2048 }
        "Disk Write" { $results = Start-DiskWriteTest -Duration $Duration }
        "Disk Read" { $results = Start-DiskReadTest -Duration $Duration }
        "Network" { $results = Start-NetworkTest -Duration $Duration }
        "GPU" { $results = Start-GPUTest -Duration $Duration }
        "CPU Math" { $results = Start-CPUMathTest -Duration $Duration }
        "Memory Bandwidth" { $results = Start-MemoryBandwidthTest -Duration $Duration }
        "GPU Threads" { $results = Start-GPUThreadTest -Duration $Duration }
        "File System" { $results = Start-FileSystemTest -Duration $Duration }
        "Video Playback" { $results = Start-VideoPlaybackTest -Duration $Duration }
        default { $results = "Invalid test type selected." }
    }
    return $results
}

Show-Menu
