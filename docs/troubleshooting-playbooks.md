# Windows IT Support Troubleshooting Playbooks

Structured playbooks for common Windows support requests. Use them only on systems you own or are authorized to support, and follow your organization’s approved policies, tools, change procedures, and escalation paths.

## Support Principles

Use the same approach for every ticket:

1. Confirm the symptom, user impact, timing, and scope.
2. Check for known outages, maintenance, or related tickets.
3. Collect relevant evidence before changing settings.
4. Start with the least disruptive approved action.
5. Validate the result technically and with the user.
6. Record the symptom, evidence, actions, outcome, and escalation details.
7. Escalate when the issue exceeds your access, authority, or support scope.

Do not disable security tools, change firewall policies, alter identity settings, or make production infrastructure changes without authorization.

## Playbook: Slow Windows Computer

### Symptoms

- Long startup or sign-in time.
- Applications take a long time to open or stop responding.
- System is slow during normal tasks.
- User reports frequent freezing, high fan noise, or low available storage.

### Evidence to Collect

```powershell
# Check how long the computer has been running.
(Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime

# Review fixed-disk free space.
Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 3" |
    Select-Object DeviceID,
        @{Name = "SizeGB"; Expression = { [math]::Round($_.Size / 1GB, 2) } },
        @{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } }

# Review the most CPU-intensive processes.
Get-Process |
    Sort-Object CPU -Descending |
    Select-Object -First 10 Name, Id, CPU, WorkingSet64

# Review recent System errors.
Get-WinEvent -FilterHashtable @{
    LogName = "System"
    Level = 2
    StartTime = (Get-Date).AddDays(-7)
} -ErrorAction SilentlyContinue |
    Select-Object -First 10 TimeCreated, ProviderName, Id, Message
```

### Troubleshooting Steps

1. Confirm whether the issue affects one application or the entire device.
2. Ask when the slowdown began and whether it started after a Windows update, application installation, storage warning, or peripheral change.
3. Verify available disk space and identify low-storage conditions.
4. Check whether the device has been restarted recently.
5. Close only user-approved unnecessary applications; save work first.
6. Use Task Manager or approved endpoint tools to identify unusually high CPU, memory, disk, or network use.
7. Check Windows Update status and restart if updates are pending and the user approves.
8. Review recent errors for storage, driver, update, or hardware-related patterns.
9. Test the user’s original task after each approved change.
10. Escalate recurring, hardware-related, security-related, or organization-wide performance issues.

### Escalate When

- The device shows repeated blue screens, boot errors, disk errors, or suspected hardware failure.
- Endpoint protection reports malware or a security concern.
- Storage is critically low and cleanup requires deleting business data.
- A required application, driver, or update needs administrator access or specialized support.
- Multiple devices show the same performance issue.

## Playbook: No Sound or Microphone

### Symptoms

- No audio from speakers, headphones, or a dock.
- Microphone does not work in meetings or recording applications.
- Audio device is missing, muted, or using the wrong output/input device.

### Evidence to Collect

```powershell
# Check audio-related services.
Get-Service -Name Audiosrv, AudioEndpointBuilder |
    Select-Object Name, DisplayName, Status, StartType

# Check for devices reporting an error in Device Manager.
Get-PnpDevice |
    Where-Object { $_.Status -ne "OK" } |
    Select-Object Class, FriendlyName, Status, Problem
```

### Troubleshooting Steps

1. Confirm whether the issue is output audio, microphone input, or both.
2. Check physical controls: headset connection, cable, dock, mute button, headset mute switch, and volume controls.
3. In Windows sound settings, verify the correct output and input devices are selected.
4. Use the built-in test feature to test speakers and microphone.
5. Confirm the affected meeting or media application is using the same intended audio devices.
6. Check that application-level volume is not muted in Volume Mixer.
7. Disconnect and reconnect the headset, dock, or USB audio device.
8. Verify the Windows Audio and Windows Audio Endpoint Builder services are running.
9. Check Device Manager for driver or device warnings.
10. Restart the application, then restart the workstation if the issue remains and the user approves.
11. Test with a known-good approved headset or a different USB port when available.
12. Escalate if there is a suspected hardware failure, unsupported driver requirement, or widespread conferencing-service outage.

### Escalate When

- The audio device does not appear after basic checks and reconnection.
- Device Manager shows persistent errors after approved troubleshooting.
- The issue affects multiple users on the same conferencing service.
- Repair requires a driver installation, BIOS change, hardware replacement, or elevated action outside your authorization.

## Playbook: Printer Offline or Stuck Print Job

### Symptoms

- Printer shows as offline.
- Print jobs remain queued, paused, or fail.
- User can print from another device but not their Windows workstation.
- Printer is reachable but output is incorrect or delayed.

### Evidence to Collect

```powershell
# Check whether the Print Spooler is running.
Get-Service -Name Spooler |
    Select-Object Name, DisplayName, Status, StartType

# View installed printers.
Get-Printer |
    Select-Object Name, DriverName, PortName, Shared, Type

# View queued jobs.
Get-PrintJob -PrinterName "<approved-printer-name>"
```

Replace `<approved-printer-name>` with the printer name from the organization’s approved inventory or the user’s Windows printer list.

### Troubleshooting Steps

1. Confirm the printer name, location, and whether another user can print to it.
2. Check printer power, paper, toner/ink, physical error messages, and network connection where accessible.
3. Confirm the user selected the correct printer and that it is not paused or set to “Use Printer Offline.”
4. Verify the correct printer is set as default if the user expects one default device.
5. Review the queue for a stuck job; cancel only the affected job after confirming with the user.
6. Confirm the Print Spooler service is running.
7. Restart the Print Spooler only when approved; this can clear queued jobs.
8. Remove and re-add the printer only if approved and if the printer deployment process supports it.
9. Print a test page and confirm the user’s application can print.
10. Escalate printer hardware, print-server, driver, network, or permission issues.

### Escalate When

- Multiple users cannot print to the same printer.
- The printer displays a hardware fault or needs physical service.
- A print server, driver package, port, network, or permissions change is required.
- Clearing the queue could affect a shared or business-critical print workload.
- The issue involves secure-print release, badge authentication, or sensitive documents.

## Playbook: Account Lockout or Repeated Sign-In Failure

### Symptoms

- User receives an account-locked, password-incorrect, or repeated sign-in prompt.
- Email, VPN, collaboration tools, mobile devices, or mapped drives repeatedly request credentials.
- The user can sign in to one service but not another.

### Evidence to Collect

- Exact error message and time of the most recent failure.
- Affected service or application.
- Whether the user recently changed their password.
- Whether the issue occurs on another approved device or web browser.
- Whether the user has old saved credentials on a phone, tablet, mapped drive, VPN client, email client, or scheduled process.
- Identity-system audit details only if you are authorized to access them.

### Troubleshooting Steps

1. Verify the user’s identity according to organization policy before discussing, unlocking, or resetting an account.
2. Confirm the username or sign-in address is correct.
3. Check for a known identity-service outage or maintenance event.
4. Determine whether the account is locked, the password expired, multifactor authentication failed, or only one application is affected.
5. If authorized, use the approved identity-management process to unlock or reset the account.
6. Have the user update stored credentials on approved devices and applications after a password change.
7. Ask the user to retry only after verifying the correct sign-in details and required multifactor method.
8. Document the source of repeated credential prompts if identified.
9. Escalate suspicious sign-in activity, repeated lockouts with no clear cause, privilege requests, or identity-system errors.

### Security Notes

- Never ask users to send passwords through email, chat, ticket comments, or screenshots.
- Never bypass multifactor authentication or disable account-protection controls to resolve a ticket.
- Follow the organization’s identity-verification process before account recovery actions.
- Repeated lockouts can result from outdated saved passwords, but they can also signal a security issue; treat unexplained cases carefully.

### Escalate When

- You cannot verify the requester’s identity.
- A lockout repeatedly returns after approved password and credential updates.
- Audit evidence suggests unfamiliar locations, devices, applications, or possible credential compromise.
- The request involves administrator, privileged, shared, or executive accounts.
- The identity-management platform or authentication service is unavailable.

## Playbook: Windows Update Fails or Remains Pending

### Symptoms

- Windows Update reports an error.
- Updates repeatedly download or install unsuccessfully.
- The device requires a restart but the update does not complete.
- A recent update is suspected to have affected an application, driver, printer, or device function.

### Evidence to Collect

```powershell
# Check free space on fixed disks.
Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 3" |
    Select-Object DeviceID,
        @{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) } }

# Confirm Windows Update-related services exist and review their status.
Get-Service -Name wuauserv, BITS, CryptSvc |
    Select-Object Name, DisplayName, Status, StartType

# Review recent Windows Update client events.
Get-WinEvent -FilterHashtable @{
    LogName = "Microsoft-Windows-WindowsUpdateClient/Operational"
    StartTime = (Get-Date).AddDays(-7)
} -ErrorAction SilentlyContinue |
    Select-Object -First 20 TimeCreated, Id, LevelDisplayName, Message
```

### Troubleshooting Steps

1. Record the exact update error code, update name, and approximate failure time.
2. Confirm the device has sufficient disk space, stable power, and network access.
3. Confirm whether a restart is pending and schedule it with the user.
4. Check for a known issue or organization-wide endpoint-management update pause.
5. Use the approved Windows Update troubleshooting tool or endpoint-management process.
6. Retry the update after approved troubleshooting and a restart.
7. If a recent update caused a business-impacting issue, gather evidence and follow the organization’s rollback or incident procedures.
8. Escalate repeated failures, servicing-stack issues, update-policy conflicts, or managed-device deployment problems.

### Escalate When

- The device cannot boot, repeatedly rolls back updates, or shows blue-screen errors.
- The failure affects multiple managed devices.
- The update requires policy, management-platform, driver, firmware, or security-baseline changes.
- The issue involves a security update that cannot be applied within the organization’s required timeline.
- A rollback, reimage, or repair installation is being considered.

## Ticket Documentation Template

```text
Issue:
[Clear user-reported symptom and affected service/device.]

Impact:
[What the user cannot do; whether business work is blocked.]

Scope:
[One user/device, multiple users, one location, or organization-wide.]

Evidence:
[Relevant error messages, configuration status, test results, and time window.]

Actions:
[Approved troubleshooting steps taken.]

Validation:
[Technical test performed and user confirmation.]

Outcome:
[Resolved, workaround provided, monitoring, or escalated.]

Escalation:
[Responsible team, ticket/incident reference, sanitized evidence, and next action.]
```
