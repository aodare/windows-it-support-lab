<#
.SYNOPSIS
    Creates a basic Windows workstation inventory report for IT support.

.DESCRIPTION
    Collects non-secret system, operating-system, hardware, storage, network,
    uptime, and selected-service information. Output is written to a timestamped
    text file in a local reports directory.

.NOTES
    Run only on devices you own or are authorized to support.
    Review generated reports before sharing because they can contain device and
    network identifiers.
#>

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReportDirectory = Join-Path $ScriptRoot "..\reports"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportPath = Join-Path $ReportDirectory "system_inventory_$Timestamp.txt"

New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null

function Add-ReportSection {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Add-Content -Path $ReportPath -Value ""
    Add-Content -Path $ReportPath -Value ("=" * 72)
    Add-Content -Path $ReportPath -Value $Title
    Add-Content -Path $ReportPath -Value ("=" * 72)
}

function Add-ReportText {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Text
    )

    Add-Content -Path $ReportPath -Value $Text
}

function Add-ReportObject {
    param(
        [Parameter(Mandatory = $true)]
        [object]$InputObject
    )

    $InputObject |
        Format-Table -AutoSize |
        Out-String -Width 200 |
        Add-Content -Path $ReportPath
}

try {
    "Windows IT Support Lab - System Inventory" | Set-Content -Path $ReportPath
    "Generated (local time): $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" |
        Add-Content -Path $ReportPath

    Add-ReportSection -Title "System Information"
    $ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
    $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $BIOS = Get-CimInstance -ClassName Win32_BIOS
    $Processor = Get-CimInstance -ClassName Win32_Processor

    [pscustomobject]@{
        ComputerName       = $env:COMPUTERNAME
        CurrentUser        = "$env:USERDOMAIN\$env:USERNAME"
        Manufacturer       = $ComputerSystem.Manufacturer
        Model              = $ComputerSystem.Model
        WindowsCaption     = $OperatingSystem.Caption
        WindowsVersion     = $OperatingSystem.Version
        OSBuildNumber      = $OperatingSystem.BuildNumber
        SystemType         = $ComputerSystem.SystemType
        BIOSVersion        = ($BIOS.SMBIOSBIOSVersion -join ", ")
        Processor          = ($Processor.Name -join ", ")
        InstalledMemoryGB  = [math]::Round($ComputerSystem.TotalPhysicalMemory / 1GB, 2)
        LastBootTime       = $OperatingSystem.LastBootUpTime
        UptimeHours        = [math]::Round(((Get-Date) - $OperatingSystem.LastBootUpTime).TotalHours, 2)
    } | Format-List | Out-String | Add-Content -Path $ReportPath

    Add-ReportSection -Title "Fixed Disk Usage"
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" |
        Select-Object `
            DeviceID,
            VolumeName,
            @{Name = "SizeGB"; Expression = { [math]::Round($_.Size / 1GB, 2) } },
            @{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } },
            @{
                Name = "FreePercent"
                Expression = {
                    if ($_.Size -gt 0) {
                        [math]::Round(($_.FreeSpace / $_.Size) * 100, 2)
                    }
                }
            } |
        Add-ReportObject

    Add-ReportSection -Title "Network Configuration"
    Get-NetIPConfiguration |
        Where-Object { $_.IPv4Address -or $_.IPv6Address } |
        Select-Object `
            InterfaceAlias,
            InterfaceDescription,
            @{Name = "IPv4Address"; Expression = { $_.IPv4Address.IPAddress -join ", " } },
            @{Name = "IPv6Address"; Expression = { $_.IPv6Address.IPAddress -join ", " } },
            @{Name = "IPv4Gateway"; Expression = { $_.IPv4DefaultGateway.NextHop -join ", " } },
            @{Name = "DNSServers"; Expression = { $_.DNSServer.ServerAddresses -join ", " } } |
        Add-ReportObject

    Add-ReportSection -Title "Network Adapter Status"
    Get-NetAdapter |
        Select-Object Name, InterfaceDescription, Status, LinkSpeed, MacAddress |
        Add-ReportObject

    Add-ReportSection -Title "Selected Windows Services"
    $ServiceNames = @(
        "wuauserv",
        "BITS",
        "Dhcp",
        "Dnscache",
        "EventLog",
        "LanmanWorkstation",
        "Spooler",
        "WinRM"
    )

    Get-Service -Name $ServiceNames -ErrorAction SilentlyContinue |
        Select-Object Name, DisplayName, Status, StartType |
        Add-ReportObject

    Add-ReportSection -Title "Recent System Errors"
    Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        Level     = 2
        StartTime = (Get-Date).AddDays(-7)
    } -ErrorAction SilentlyContinue |
        Select-Object -First 10 TimeCreated, ProviderName, Id, LevelDisplayName, Message |
        Format-List |
        Out-String -Width 200 |
        Add-Content -Path $ReportPath

    Add-ReportSection -Title "Report Notes"
    Add-ReportText -Text "This report is intended for authorized IT support and troubleshooting."
    Add-ReportText -Text "Review and sanitize machine-specific information before sharing."

    Write-Host "System inventory report created: $ReportPath" -ForegroundColor Green
}
catch {
    Write-Error "Unable to create system inventory report: $($_.Exception.Message)"
    exit 1
}
