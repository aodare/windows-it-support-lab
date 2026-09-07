<#
.SYNOPSIS
    Performs basic Windows workstation health checks for IT support.

.DESCRIPTION
    Checks disk free space, device uptime, selected Windows services,
    DNS name resolution, and HTTPS connectivity. The script writes a
    timestamped text report to a local reports folder.

.NOTES
    Run only on devices you own or are authorized to support.
    Review generated reports before sharing because reports may contain
    device and network identifiers.
#>

$ErrorActionPreference = "Stop"

$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$ReportDirectory = Join-Path $ScriptRoot "..\reports"
$Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$ReportPath = Join-Path $ReportDirectory "basic_health_check_$Timestamp.txt"

$DiskFreeWarningPercent = 15
$UptimeWarningDays = 14
$DnsTestName = "www.microsoft.com"
$TcpTestHost = "www.microsoft.com"
$TcpTestPort = 443

New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null

function Add-ReportLine {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Add-Content -Path $ReportPath -Value $Message
}

function Write-CheckResult {
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet("PASS", "WARNING", "FAIL", "INFO")]
        [string]$Status,

        [Parameter(Mandatory = $true)]
        [string]$Check,

        [Parameter(Mandatory = $true)]
        [string]$Details
    )

    $Line = "[{0}] {1}: {2}" -f $Status, $Check, $Details
    Add-ReportLine -Message $Line

    switch ($Status) {
        "PASS"    { Write-Host $Line -ForegroundColor Green }
        "WARNING" { Write-Host $Line -ForegroundColor Yellow }
        "FAIL"    { Write-Host $Line -ForegroundColor Red }
        default   { Write-Host $Line -ForegroundColor Cyan }
    }
}

try {
    "Windows IT Support Lab - Basic Health Check" | Set-Content -Path $ReportPath
    "Generated (local time): $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" |
        Add-Content -Path $ReportPath
    Add-ReportLine -Message ("=" * 72)

    Write-CheckResult -Status "INFO" `
        -Check "Device" `
        -Details "Computer: $env:COMPUTERNAME | User: $env:USERDOMAIN\$env:USERNAME"

    Write-CheckResult -Status "INFO" `
        -Check "Thresholds" `
        -Details "Disk warning below $DiskFreeWarningPercent% free; uptime warning above $UptimeWarningDays days"

    Add-ReportLine -Message ""
    Add-ReportLine -Message "Disk Checks"
    Add-ReportLine -Message ("-" * 72)

    $FixedDisks = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"

    foreach ($Disk in $FixedDisks) {
        if ($Disk.Size -le 0) {
            Write-CheckResult -Status "WARNING" `
                -Check "Disk $($Disk.DeviceID)" `
                -Details "Could not determine disk capacity."
            continue
        }

        $FreePercent = [math]::Round(($Disk.FreeSpace / $Disk.Size) * 100, 2)
        $FreeGB = [math]::Round($Disk.FreeSpace / 1GB, 2)
        $SizeGB = [math]::Round($Disk.Size / 1GB, 2)

        $DiskStatus = if ($FreePercent -lt $DiskFreeWarningPercent) {
            "WARNING"
        }
        else {
            "PASS"
        }

        Write-CheckResult -Status $DiskStatus `
            -Check "Disk $($Disk.DeviceID)" `
            -Details "$FreeGB GB free of $SizeGB GB ($FreePercent% free)"
    }

    Add-ReportLine -Message ""
    Add-ReportLine -Message "Uptime Check"
    Add-ReportLine -Message ("-" * 72)

    $OperatingSystem = Get-CimInstance -ClassName Win32_OperatingSystem
    $Uptime = (Get-Date) - $OperatingSystem.LastBootUpTime
    $UptimeDays = [math]::Round($Uptime.TotalDays, 2)

    $UptimeStatus = if ($Uptime.TotalDays -ge $UptimeWarningDays) {
        "WARNING"
    }
    else {
        "PASS"
    }

    Write-CheckResult -Status $UptimeStatus `
        -Check "System Uptime" `
        -Details "$UptimeDays days since last restart ($($OperatingSystem.LastBootUpTime))"

    Add-ReportLine -Message ""
    Add-ReportLine -Message "Service Checks"
    Add-ReportLine -Message ("-" * 72)

    $RequiredServices = @(
        @{
            Name = "Dhcp"
            Purpose = "Obtains network configuration automatically"
        },
        @{
            Name = "Dnscache"
            Purpose = "Caches DNS name-resolution results"
        },
        @{
            Name = "EventLog"
            Purpose = "Records Windows event logs"
        },
        @{
            Name = "LanmanWorkstation"
            Purpose = "Provides network client connectivity"
        }
    )

    foreach ($RequiredService in $RequiredServices) {
        $Service = Get-Service -Name $RequiredService.Name -ErrorAction SilentlyContinue

        if (-not $Service) {
            Write-CheckResult -Status "FAIL" `
                -Check "Service $($RequiredService.Name)" `
                -Details "Service was not found. Expected purpose: $($RequiredService.Purpose)"
        }
        elseif ($Service.Status -ne "Running") {
            Write-CheckResult -Status "WARNING" `
                -Check "Service $($RequiredService.Name)" `
                -Details "Status: $($Service.Status). Expected purpose: $($RequiredService.Purpose)"
        }
        else {
            Write-CheckResult -Status "PASS" `
                -Check "Service $($RequiredService.Name)" `
                -Details "Running. Purpose: $($RequiredService.Purpose)"
        }
    }

    Add-ReportLine -Message ""
    Add-ReportLine -Message "Network Checks"
    Add-ReportLine -Message ("-" * 72)

    try {
        $DnsResult = Resolve-DnsName -Name $DnsTestName -Type A -ErrorAction Stop |
            Where-Object { $_.IPAddress } |
            Select-Object -First 1

        if ($DnsResult) {
            Write-CheckResult -Status "PASS" `
                -Check "DNS Resolution" `
                -Details "$DnsTestName resolved to $($DnsResult.IPAddress)"
        }
        else {
            Write-CheckResult -Status "WARNING" `
                -Check "DNS Resolution" `
                -Details "$DnsTestName returned no IPv4 address record."
        }
    }
    catch {
        Write-CheckResult -Status "FAIL" `
            -Check "DNS Resolution" `
            -Details "Unable to resolve $DnsTestName. Error: $($_.Exception.Message)"
    }

    try {
        $TcpResult = Test-NetConnection `
            -ComputerName $TcpTestHost `
            -Port $TcpTestPort `
            -InformationLevel Detailed `
            -WarningAction SilentlyContinue

        if ($TcpResult.TcpTestSucceeded) {
            Write-CheckResult -Status "PASS" `
                -Check "HTTPS Connectivity" `
                -Details "TCP port $TcpTestPort reachable on $TcpTestHost"
        }
        else {
            Write-CheckResult -Status "FAIL" `
                -Check "HTTPS Connectivity" `
                -Details "TCP port $TcpTestPort was not reachable on $TcpTestHost"
        }
    }
    catch {
        Write-CheckResult -Status "FAIL" `
            -Check "HTTPS Connectivity" `
            -Details "Unable to test $TcpTestHost on port $TcpTestPort. Error: $($_.Exception.Message)"
    }

    Add-ReportLine -Message ""
    Add-ReportLine -Message ("=" * 72)
    Add-ReportLine -Message "Health-check report complete."
    Add-ReportLine -Message "Review and sanitize any report before sharing."

    Write-Host ""
    Write-Host "Health-check report created: $ReportPath" -ForegroundColor Green
}
catch {
    Write-Error "Unable to complete health check: $($_.Exception.Message)"
    exit 1
}
