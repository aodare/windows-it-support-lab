# Windows Workstation Setup and Verification Checklist

A repeatable checklist for preparing and validating a Windows workstation in a lab, home environment, or authorized support environment.

## Scope

Use this checklist for a new or reimaged Windows workstation after the operating system has been installed. Follow your organization’s approved imaging, endpoint-management, security, asset-management, and change-management procedures when working in a production environment.

Do not use this document as a substitute for company policy or security baselines.

## Before Setup

- Confirm the assigned user, intended device purpose, and required applications.
- Verify that the device has an approved Windows license and supported Windows version.
- Record required asset information in the organization’s approved asset-management system.
- Confirm you have authorization to configure the device.
- Connect the workstation to approved power and network resources.
- Verify that a current backup or known-good recovery option exists before making major changes.

## Initial Configuration

1. Start Windows and complete the organization-approved out-of-box or imaging process.
2. Set the correct region, keyboard layout, time zone, date, and time.
3. Connect to the approved wired or wireless network.
4. Confirm the device receives a valid IP address, default gateway, and DNS server configuration.
5. Sign in with the approved user or administrator account.
6. Rename the device according to the organization’s naming standard, when authorized.
7. Join the device to the approved identity environment, such as a Windows domain or cloud directory, when required.
8. Enroll the device in the organization’s approved endpoint-management and security tools.
9. Confirm that full-disk encryption and endpoint protection are enabled according to policy.
10. Install required applications only from approved sources.

## Windows Update Verification

1. Open **Settings** → **Windows Update**.
2. Select **Check for updates**.
3. Install approved operating-system, driver, and security updates.
4. Restart the workstation when prompted.
5. Run **Check for updates** again after restart.
6. Confirm there are no pending critical updates or restart requirements.
7. Record update status in the support ticket or asset record when required.

## Account and Access Verification

- Confirm the assigned user can sign in successfully.
- Verify the user has standard-user permissions unless elevated access is specifically approved.
- Confirm multi-factor authentication or other required sign-in controls work.
- Verify required access to approved email, collaboration, file-storage, VPN, and business applications.
- Test access to required network shares, printers, or remote resources where applicable.
- Do not test access to data or systems outside the user’s authorized role.

## Hardware and Peripheral Verification

- Confirm the display, keyboard, touchpad or mouse, webcam, speakers, microphone, and headset work.
- Test wired and wireless network connectivity.
- Verify Bluetooth only if the user requires it.
- Test required USB devices, docks, monitors, printers, scanners, or smart-card readers.
- Confirm battery charging and power-management behavior on laptops.
- Check **Device Manager** for unknown devices or hardware warnings.
- Verify adequate disk capacity for the user’s expected workload.

## Security Verification

- Confirm endpoint protection is active and receiving updates.
- Confirm the firewall is enabled according to policy.
- Confirm full-disk encryption status according to policy.
- Ensure the user does not receive unnecessary local-administrator permissions.
- Verify automatic screen lock and password or sign-in requirements.
- Confirm approved backup, synchronization, or data-protection controls are enabled where required.
- Remove temporary setup accounts, test files, and installation media before handoff.

## Final Validation

1. Restart the workstation and confirm it starts normally.
2. Sign in as the assigned user and verify the desktop loads without errors.
3. Run the repository’s health-check script:

   ```powershell
   .\scripts\basic-health-check.ps1
   ```

4. Review any `WARNING` or `FAIL` result before handing off the device.
5. Confirm the user can complete one or two core job tasks.
6. Provide required handoff information, such as first-sign-in guidance, support contact details, and equipment return expectations.
7. Update the approved ticket or asset record with completed setup and verification steps.
8. Close the request only after the user or requester confirms the device is ready.

## Documentation Example

Use concise, factual notes in the approved ticketing system.

```text
Device setup completed for assigned user.

- Windows updates installed and restart completed.
- Device enrolled in approved endpoint-management and security tools.
- Network, audio, webcam, dock, and external display verified.
- User sign-in and required business applications tested.
- Basic health check completed with no unresolved failures.
- User confirmed workstation is ready for use.
```

## Escalation Triggers

Escalate according to your organization’s procedures when you encounter:

- Suspected malware, unauthorized software, or a security-policy violation.
- Disk-encryption, endpoint-protection, or device-management enrollment failures.
- Repeated update failures, boot failures, blue-screen errors, or suspected hardware defects.
- Account lockouts, identity-verification concerns, or unexpected privilege changes.
- Network issues affecting multiple users, locations, or critical services.
- Requests for access outside the user’s established role.
- Any issue requiring an unapproved configuration change or elevated permissions.
