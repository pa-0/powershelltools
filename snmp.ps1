Function Invoke-AdvancedSnmpWalk { 
    <#
        .SYNOPSIS
            Invoke-AdvancedSnmpWalk returns all objects within the subtree from SNMP.

        .DESCRIPTION
            Invoke-AdvancedSnmpWalk returns all objects within the subtree from SNMP, supporting SNMPv1, v2c, and v3, and includes additional functionalities such as output to CSV and OID type filtering.

        .PARAMETER IpAddress
            This parameter contains the node address of the agent.

        .PARAMETER OID
            This parameter contains the OID (Object IDentifier).

        .PARAMETER Force
            This lets the Walk operation break out of the subtree and returns all OIDs until node returns NULL.

        .PARAMETER Version
            This parameter specifies the SNMP version (1, 2, 3).

        .PARAMETER UserName
            This parameter specifies the SNMPv3 username.

        .PARAMETER AuthProtocol
            This parameter specifies the SNMPv3 authentication protocol (MD5, SHA).

        .PARAMETER AuthPassword
            This parameter specifies the SNMPv3 authentication password.

        .PARAMETER PrivProtocol
            This parameter specifies the SNMPv3 privacy protocol (DES, AES).

        .PARAMETER PrivPassword
            This parameter specifies the SNMPv3 privacy password.

        .PARAMETER OutputFile
            This parameter specifies the file path to save the results in CSV format.

        .PARAMETER FilterType
            This parameter allows filtering the results by OID type (e.g., Integer, OctetString).

        .EXAMPLE
            PS C:\> Invoke-AdvancedSnmpWalk -IpAddress 192.168.1.100 -OID 1.3.6.1.2.1.1 -Version 2c -Community public | ft -AutoSize

        .INPUTS
            System.String

        .LINK
            http://www.proxx.nl
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    Param(
        [String]$Community = "public",
        [Switch]$Force,
        [Parameter(
            Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
        )]
        [Alias("Address","ComputerName","IP","Node")]
        [String[]]$IpAddress,
        [Parameter(
            Mandatory=$false,
            Position=1
        )]
        [String]$OID="1.3.6.1",
        [int]$Port=161,
        [int]$Retry =  1,
        [int]$TimeOut = 2000,
        [ValidateSet("1","2c","3")]
        [String]$Version="2c",
        [String]$UserName,
        [ValidateSet("MD5","SHA")]
        [String]$AuthProtocol,
        [String]$AuthPassword,
        [ValidateSet("DES","AES")]
        [String]$PrivProtocol,
        [String]$PrivPassword,
        [String]$OutputFile,
        [String]$FilterType
    )
    Begin {
        $RootOID = if (-not $Force) { [SnmpSharpNet.Oid]$OID } else { $null }
        $SimpleSnmp = New-Object -TypeName SnmpSharpNet.SimpleSnmp
        $SimpleSnmp.Community = $Community
        $SimpleSnmp.Retry = $Retry
        $SimpleSnmp.PeerPort = $Port
        $SimpleSnmp.Timeout = $TimeOut
        
        $Ver = switch ($Version) {
            "1" { [SnmpSharpNet.SnmpVersion]::Ver1 }
            "2c" { [SnmpSharpNet.SnmpVersion]::Ver2 }
            "3" { [SnmpSharpNet.SnmpVersion]::Ver3 }
        }

        if ($Version -eq "3") {
            $SimpleSnmp.SetV3($UserName, $AuthProtocol, $AuthPassword, $PrivProtocol, $PrivPassword)
        }

        $Results = @()
    }
    Process {
        ForEach($Node in $IpAddress) {
            $LastOID = $OID
            $SimpleSnmp.PeerIP = $Node
            $SimpleSnmp.PeerName = $Node
            While ($null -ne $LastOID) {
                $Response = $SimpleSnmp.GetNext($Ver, $LastOID)
                if ($Response) {
                    if ($Response.Count -gt 0) {
                        ForEach ($var in $Response.GetEnumerator()) {
                            $Type = [SnmpSharpNet.SnmpConstants]::GetTypeName($var.Value.Type)
                            if (-not $FilterType -or $Type -eq $FilterType) {
                                $Object = [PSCustomObject] @{
                                    Node = $Node
                                    OID = $var.Key.ToString()
                                    Type = $Type
                                    Value = $var.Value.ToString()
                                }
                                $Results += $Object
                                if (-not $Force -and -not $RootOID.IsRootOf($var.Key)) { $LastOID = $null; break }
                                $LastOID = $var.Key.ToString()
                                Write-Output -InputObject $Object
                            }
                        }
                    } else { $LastOID = $null }
                } else { Write-Warning -Message "OID returned Null $LastOID"; $LastOID = $null }
            }
        }
    }
    End {
        if ($OutputFile) {
            $Results | Export-Csv -Path $OutputFile -NoTypeInformation
        }
    }
}

# Example usage:
# Invoke-AdvancedSnmpWalk -IpAddress 192.168.1.100 -OID 1.3.6.1.2.1.1 -Version 2c -Community public -OutputFile "results.csv" -FilterType "OctetString"