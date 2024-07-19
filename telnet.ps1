param(
    [string]$Mode,
    [string]$Address = "",
    [int]$Port,
    [switch]$UDP = $false
)

function Show-Help {
    Write-Output @"
Usage: .\Netcat.ps1 -Mode <listen|connect> -Address <IP> -Port <port> [-UDP]

-MODE <listen|connect> : Specify 'listen' to start listening on the port or 'connect' to connect to an address.
-ADDRESS <IP> : IP address to connect to or to listen for incoming connections (for 'connect' mode).
-PORT <port> : Port number to listen on or connect to.
-UDP : Use UDP instead of TCP. Optional.
"@
}

function Start-TCPListener {
    param (
        [int]$Port
    )

    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $Port)
    $listener.Start()
    Write-Output "Listening on TCP port $Port..."

    $client = $listener.AcceptTcpClient()
    Write-Output "Connection accepted from $($client.Client.RemoteEndPoint.Address):$($client.Client.RemoteEndPoint.Port)"
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    # Thread for reading data
    $readThread = [System.Threading.Thread]::new({
        param ($reader)
        while ($true) {
            if ($reader.Peek() -ge 0) {
                $data = $reader.ReadLine()
                Write-Output "Received: $data"
            }
        }
    }, $reader)

    $readThread.Start()

    while ($client.Connected) {
        $input = Read-Host -Prompt "Send"
        $writer.WriteLine($input)
    }

    $client.Close()
    $listener.Stop()
}

function Start-TCPClient {
    param (
        [string]$Address,
        [int]$Port
    )

    $client = New-Object System.Net.Sockets.TcpClient($Address, $Port)
    Write-Output "Connected to $Address on TCP port $Port"
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    # Thread for reading data
    $readThread = [System.Threading.Thread]::new({
        param ($reader)
        while ($true) {
            if ($reader.Peek() -ge 0) {
                $data = $reader.ReadLine()
                Write-Output "Received: $data"
            }
        }
    }, $reader)

    $readThread.Start()

    while ($client.Connected) {
        $input = Read-Host -Prompt "Send"
        $writer.WriteLine($input)
    }

    $client.Close()
}

function Start-UDPListener {
    param (
        [int]$Port
    )

    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, $Port)
    $udpClient = New-Object System.Net.Sockets.UdpClient($Port)
    Write-Output "Listening on UDP port $Port..."

    # Thread for reading data
    $readThread = [System.Threading.Thread]::new({
        param ($udpClient, $endpoint)
        while ($true) {
            $receivedResult = $udpClient.Receive([ref]$endpoint)
            $data = [System.Text.Encoding]::UTF8.GetString($receivedResult)
            Write-Output "Received: $data from $($endpoint.Address):$($endpoint.Port)"
        }
    }, $udpClient, $endpoint)

    $readThread.Start()

    while ($true) {
        Start-Sleep -Seconds 1
    }

    $udpClient.Close()
}

function Start-UDPClient {
    param (
        [string]$Address,
        [int]$Port
    )

    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($Address), $Port)
    $udpClient = New-Object System.Net.Sockets.UdpClient
    Write-Output "Connected to $Address on UDP port $Port"

    # Thread for reading data
    $readThread = [System.Threading.Thread]::new({
        param ($udpClient, $endpoint)
        while ($true) {
            $receivedResult = $udpClient.Receive([ref]$endpoint)
            $data = [System.Text.Encoding]::UTF8.GetString($receivedResult)
            Write-Output "Received: $data from $($endpoint.Address):$($endpoint.Port)"
        }
    }, $udpClient, $endpoint)

    $readThread.Start()

    while ($true) {
        $input = Read-Host -Prompt "Send"
        $sendBytes = [System.Text.Encoding]::UTF8.GetBytes($input)
        $udpClient.Send($sendBytes, $sendBytes.Length, $endpoint)
    }

    $udpClient.Close()
}

if ($Mode -eq "listen") {
    if ($UDP) {
        Start-UDPListener -Port $Port
    } else {
        Start-TCPListener -Port $Port
    }
} elseif ($Mode -eq "connect") {
    if ($UDP) {
        Start-UDPClient -Address $Address -Port $Port
    } else {
        Start-TCPClient -Address $Address -Port $Port
    }
} else {
    Show-Help
}
