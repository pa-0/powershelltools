param (
    [string]$mode,
    [string]$address,
    [int]$port,
    [string]$protocol = "tcp"
)

function Show-Help {
    Write-Output @"
Usage: .\Netcat.ps1 -mode <listen|connect> -address <IP> -port <port> [-protocol <tcp|udp>]

-m    --mode       Mode of operation: 'listen' or 'connect'
-a    --address    IP address to connect to (required in 'connect' mode)
-p    --port       Port number to listen on or connect to
-pr   --protocol   Protocol to use: 'tcp' (default) or 'udp'
-h    --help       Show this help message
"@
}

function Start-TCPListener {
    param (
        [int]$port
    )

    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Any, $port)
    $listener.Start()
    Write-Output "Listening on TCP port $port..."

    while ($true) {
        $client = $listener.AcceptTcpClient()
        Write-Output "Connection accepted from $($client.Client.RemoteEndPoint.Address):$($client.Client.RemoteEndPoint.Port)"
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $true

        while ($client.Connected) {
            if ($stream.DataAvailable) {
                $data = $reader.ReadLine()
                Write-Output "Received: $data"
            }

            $input = Read-Host
            $writer.WriteLine($input)
        }

        $client.Close()
    }

    $listener.Stop()
}

function Start-TCPClient {
    param (
        [string]$address,
        [int]$port
    )

    $client = New-Object System.Net.Sockets.TcpClient($address, $port)
    Write-Output "Connected to $address on TCP port $port"
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    while ($client.Connected) {
        $input = Read-Host
        $writer.WriteLine($input)

        if ($stream.DataAvailable) {
            $data = $reader.ReadLine()
            Write-Output "Received: $data"
        }
    }

    $client.Close()
}

function Start-UDPListener {
    param (
        [int]$port
    )

    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any, $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient($port)
    Write-Output "Listening on UDP port $port..."

    while ($true) {
        $receivedResult = $udpClient.Receive([ref]$endpoint)
        $data = [System.Text.Encoding]::UTF8.GetString($receivedResult)
        Write-Output "Received: $data from $($endpoint.Address):$($endpoint.Port)"
        
        $input = Read-Host
        $sendBytes = [System.Text.Encoding]::UTF8.GetBytes($input)
        $udpClient.Send($sendBytes, $sendBytes.Length, $endpoint)
    }

    $udpClient.Close()
}

function Start-UDPClient {
    param (
        [string]$address,
        [int]$port
    )

    $endpoint = New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Parse($address), $port)
    $udpClient = New-Object System.Net.Sockets.UdpClient
    Write-Output "Connected to $address on UDP port $port"

    while ($true) {
        $input = Read-Host
        $sendBytes = [System.Text.Encoding]::UTF8.GetBytes($input)
        $udpClient.Send($sendBytes, $sendBytes.Length, $endpoint)
        
        $receivedResult = $udpClient.Receive([ref]$endpoint)
        $data = [System.Text.Encoding]::UTF8.GetString($receivedResult)
        Write-Output "Received: $data from $($endpoint.Address):$($endpoint.Port)"
    }

    $udpClient.Close()
}

if ($mode -eq "listen") {
    if ($protocol -eq "tcp") {
        Start-TCPListener -port $port
    } elseif ($protocol -eq "udp") {
        Start-UDPListener -port $port
    } else {
        Show-Help
    }
} elseif ($mode -eq "connect") {
    if ($protocol -eq "tcp") {
        Start-TCPClient -address $address -port $port
    } elseif ($protocol -eq "udp") {
        Start-UDPClient -address $address -port $port
    } else {
        Show-Help
    }
} else {
    Show-Help
}
