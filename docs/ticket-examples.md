# Fictional IT Support Ticket Examples

These examples are fictional and use documentation-safe placeholder names, dates, and IP addresses. They are included to demonstrate clear ticket writing, structured troubleshooting, validation, escalation, and privacy-aware support practices.

Do not copy real ticket data, user names, hostnames, IP addresses, error logs, screenshots, or organization-specific configuration into this public repository.

## Example 1: Slow Workstation Caused by Low Disk Space

### Ticket Summary

| Field | Value |
|---|---|
| Ticket ID | DEMO-1001 |
| Category | Windows workstation performance |
| Priority | Medium |
| Affected device | `LAB-WIN11-01` |
| User | `Demo User` |
| Status | Resolved |
| Date | 2026-09-07 |

### User Report

> My laptop has been very slow since this morning. Outlook takes several minutes to open, and I cannot download an attachment.

### Impact

The user could sign in and access the network but could not reliably use email or download documents. The issue affected one user and one device.

### Evidence Collected

```text
- Fixed disk C: had 4.8 GB free of 237 GB total capacity (approximately 2% free).
- System uptime was 18.4 days.
- No organization-wide performance incident was reported.
- The device had pending Windows updates and required a restart.
```

### Actions Taken

1. Confirmed the user had saved active work and approved troubleshooting.
2. Reviewed disk usage with the user and identified large, non-business temporary files in approved cleanup locations.
3. Used the organization-approved cleanup process; no business files were deleted.
4. Confirmed free disk space increased above the local support threshold.
5. Scheduled and completed an approved restart to apply pending updates.
6. Re-ran the basic health check.
7. Asked the user to open Outlook and download a non-sensitive test attachment.

### Validation

```text
- C: free space increased to 42 GB.
- Basic health check no longer returned a low-disk-space warning.
- Outlook opened normally.
- User successfully downloaded the test attachment.
- User confirmed normal performance was restored.
```

### Resolution Note

```text
Resolved. Low free disk space and extended uptime were identified as contributing factors.
Completed approved temporary-file cleanup and restart. Verified 42 GB free on C:,
successful Outlook launch, attachment download, and user confirmation.
```

### Privacy Note

No personal files, attachment contents, usernames, serial numbers, or real device identifiers were included in this public example.

## Example 2: Internet Access by IP but Not by Name

### Ticket Summary

| Field | Value |
|---|---|
| Ticket ID | DEMO-1002 |
| Category | Network / DNS |
| Priority | High |
| Affected device | `LAB-WIN11-02` |
| User | `Demo User` |
| Status | Escalated and resolved |
| Date | 2026-09-07 |

### User Report

> I can connect to the Wi-Fi network, but websites and our cloud application will not load.

### Impact

The user could not access browser-based work tools. The issue was limited to one device on the same network where another authorized test device worked.

### Evidence Collected

```text
- Wireless adapter status: connected.
- Device had an assigned IPv4 address, default gateway, and DNS servers.
- Default gateway reachability test: passed.
- Test to public IP address 1.1.1.1: passed.
- DNS lookup for www.microsoft.com: failed.
- Test to www.microsoft.com on TCP port 443: failed because the name did not resolve.
- DNS Client service: running.
```

### Actions Taken

1. Confirmed the problem occurred in more than one browser.
2. Compared the device’s DNS server assignment with an authorized, known-good device on the same approved network.
3. Collected sanitized evidence and did not manually change production DNS settings.
4. Escalated the issue to the network team because the endpoint appeared healthy but had an incorrect DNS assignment.
5. After the network team corrected the approved network configuration, renewed the device network connection through the organization-approved process.
6. Repeated DNS and HTTPS tests.

### Validation

```text
- DNS lookup for www.microsoft.com succeeded.
- HTTPS TCP connectivity test to www.microsoft.com on port 443 succeeded.
- Browser access to the cloud application succeeded.
- User confirmed service restoration.
```

### Escalation Note

```text
Escalated to Network Operations with sanitized evidence showing:
gateway and public-IP reachability passed; DNS name resolution failed; DNS Client
service was running. Network Operations corrected the approved DNS assignment.
```

### Resolution Note

```text
Resolved after Network Operations corrected the device's approved DNS configuration.
Verified successful DNS resolution, HTTPS connectivity, application access, and user confirmation.
```

## Example 3: VPN Connected but Internal File Share Unavailable

### Ticket Summary

| Field | Value |
|---|---|
| Ticket ID | DEMO-1003 |
| Category | Remote access / VPN |
| Priority | High |
| Affected device | `LAB-WIN11-03` |
| User | `Demo User` |
| Status | Escalated and resolved |
| Date | 2026-09-07 |

### User Report

> My VPN says connected, but I cannot open the Finance shared folder that I need for today’s work.

### Impact

The user could access public internet services but could not reach an internal file share required for a time-sensitive task.

### Evidence Collected

```text
- Approved VPN client displayed a connected state.
- Public internet access was available.
- Approved internal hostname did not resolve while the VPN was connected.
- The user could not access the required file share.
- No permissions were changed during initial troubleshooting.
- Another authorized user reported the same symptom.
```

### Actions Taken

1. Confirmed the issue involved an internal resource and not general internet access.
2. Confirmed the user was using the approved VPN client and an active connection.
3. Tested an approved internal hostname using the documented DNS-resolution process.
4. Checked the organization’s approved status channel for related service notifications.
5. Identified that the issue affected more than one authorized VPN user.
6. Escalated to the VPN/network team with sanitized test results and timing.
7. Did not alter routes, DNS settings, VPN profiles, or security controls locally.
8. Retested after the responsible team reported restoration.

### Validation

```text
- Approved internal hostname resolved successfully while connected to VPN.
- Required file share opened for the user.
- User could create and close an approved test file in the authorized location.
- User confirmed access was restored.
```

### Escalation Note

```text
Escalated because multiple VPN users could connect but could not resolve approved
internal hostnames. Issue was likely outside endpoint support scope and required
VPN/DNS infrastructure investigation.
```

### Resolution Note

```text
Resolved after VPN/DNS service restoration by the responsible infrastructure team.
Verified internal name resolution, authorized share access, and user confirmation.
```

## Example 4: Account Lockout After Password Change

### Ticket Summary

| Field | Value |
|---|---|
| Ticket ID | DEMO-1004 |
| Category | Identity and access |
| Priority | High |
| Affected account | `demo.user@example.invalid` |
| Affected device | `LAB-WIN11-04` |
| Status | Resolved |
| Date | 2026-09-07 |

### User Report

> I changed my password this morning. Now I keep getting sign-in prompts, and my account is locked again after I reset it.

### Impact

The user could not reliably access email and collaboration tools. The issue affected one account; no privileged access was involved.

### Evidence Collected

```text
- User identity was verified through the organization-approved process.
- The user had changed their password earlier the same day.
- The account re-locked after an approved reset.
- An old saved credential was identified in an approved email client on a secondary device.
- No password was requested, recorded, emailed, or added to ticket notes.
- No evidence of suspicious sign-in activity was found in the authorized review.
```

### Actions Taken

1. Verified the requester’s identity before performing account actions.
2. Confirmed no identity-service outage was active.
3. Used the approved identity-management process to reset/unlock the account.
4. Guided the user to update the saved credential in the approved email client on the secondary device.
5. Confirmed the user updated the password on approved mobile and desktop applications.
6. Asked the user to sign in again with the new credential and complete required multifactor authentication.
7. Monitored for repeat lockout according to local procedure.

### Validation

```text
- User successfully signed in to email and collaboration tools.
- No repeat lockout occurred during the verification window.
- User confirmed normal access.
```

### Resolution Note

```text
Resolved. Account repeatedly locked because an approved secondary email client was
retrying an outdated saved credential after a password change. Identity verified;
account reset/unlocked through the approved process; user updated saved credentials;
sign-in and multifactor authentication validated.
```

### Security Note

Never include passwords, recovery codes, authentication prompts, session tokens, or sensitive audit-log details in ticket comments or public documentation.

## Example 5: Printer Offline with Stuck Queue

### Ticket Summary

| Field | Value |
|---|---|
| Ticket ID | DEMO-1005 |
| Category | Printing |
| Priority | Medium |
| Affected device | `LAB-WIN11-05` |
| User | `Demo User` |
| Status | Resolved |
| Date | 2026-09-07 |

### User Report

> I sent a document to the office printer, but nothing printed. Windows says the printer is offline.

### Impact

The user could not print one non-sensitive document. Other applications and network access were functioning.

### Evidence Collected

```text
- Correct printer was selected in the user's application.
- Printer queue contained one stuck test job.
- Print Spooler service was running.
- Another authorized user could print to the same printer.
- Printer hardware displayed no paper, toner, or physical error message.
- The workstation had temporarily marked the printer as offline.
```

### Actions Taken

1. Confirmed the user was sending the job to the correct approved printer.
2. Confirmed the printer was not intentionally paused or configured to “Use Printer Offline.”
3. Confirmed with the user before canceling the stuck test job.
4. Removed the stuck job from the local queue.
5. Restarted the Print Spooler through the approved support process.
6. Confirmed the printer returned to an online state.
7. Printed a non-sensitive Windows test page.
8. Asked the user to resend the original document.

### Validation

```text
- Print Spooler service running.
- Printer showed online.
- Windows test page printed successfully.
- User's document printed successfully.
- User confirmed the issue was resolved.
```

### Resolution Note

```text
Resolved. A stuck local print job caused the workstation to retain an offline printer
state. After user approval, cleared the affected job and restarted the Print Spooler.
Validated with a Windows test page and successful user print job.
```

## Ticket-Writing Checklist

Before resolving or escalating a ticket, confirm that the record includes:

- A clear user-reported symptom and the affected service, device, or account.
- Business impact and scope: one user, multiple users, one location, or wider impact.
- Relevant time window and exact error text when available.
- Evidence collected and whether it supports a likely fault domain.
- Approved actions taken in chronological order.
- Technical validation and user confirmation of the result.
- Escalation owner, reference number, and sanitized supporting evidence when escalation is needed.
- No passwords, secrets, personal data, sensitive diagnostic output, or unnecessary internal configuration details.
