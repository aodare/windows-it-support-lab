# Windows IT Support Lab

A hands-on Windows IT support portfolio project focused on workstation inventory, basic health checks, network troubleshooting, and support documentation.

This repository demonstrates practical PowerShell and troubleshooting workflows relevant to entry-level IT support, help desk, desktop support, and junior system-administration roles.

## Project Goals

- Collect non-secret Windows workstation inventory details.
- Identify common support issues such as low disk space, extended uptime, stopped services, and basic connectivity failures.
- Practice a structured troubleshooting approach rather than relying on guesswork.
- Document support procedures and ticket work clearly.
- Apply safe handling practices for workstation reports, logs, and configuration artifacts.

## Repository Structure

```text
windows-it-support-lab/
├── README.md
├── .gitignore
├── scripts/
│   ├── system-inventory.ps1
│   └── basic-health-check.ps1
├── docs/
│   ├── workstation-setup.md
│   ├── user-and-permission-management.md
│   ├── network-troubleshooting.md
│   ├── troubleshooting-playbooks.md
│   └── ticket-examples.md
└── sample-output/
    └── sanitized-system-inventory.txt
```

## Scripts

### `system-inventory.ps1`

Creates a timestamped local text report containing non-secret workstation information, including:

- Computer name and signed-in user.
- Windows edition, version, and build.
- Manufacturer, model, BIOS version, CPU, and installed memory.
- Fixed-disk capacity and available space.
- IP configuration, DNS servers, and network-adapter status.
- Selected Windows service status.
- Recent System event-log errors.

The script writes reports to a local `reports/` folder. That folder is intentionally excluded from Git to prevent machine-specific information from being committed.

### `basic-health-check.ps1`

Runs basic workstation checks and marks results as `PASS`, `WARNING`, `FAIL`, or `INFO`.

| Check | Warning or failure condition |
|---|---|
| Fixed disks | Less than 15% free space |
| System uptime | More than 14 days since restart |
| Core services | DHCP Client, DNS Client, Event Log, or Workstation service is missing or not running |
| DNS resolution | A test DNS name cannot resolve to an IPv4 address |
| HTTPS connectivity | TCP port 443 cannot be reached on the configured test host |

## Running the Scripts

Run PowerShell as a standard user unless a task specifically requires administrator privileges.

```powershell
git clone [https://github.com/aodare/windows-it-support-lab.git](https://github.com/aodare/windows-it-support-lab.git)
cd windows-it-support-lab

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

.\scripts\system-inventory.ps1
.\scripts\basic-health-check.ps1
```

`Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` affects only the current PowerShell session. It does not permanently change the computer-wide execution-policy setting.

Review any report before sharing it. Reports may contain machine-specific details such as a hostname, username, IP addresses, DNS servers, MAC addresses, hardware details, and event information.

## Troubleshooting Workflow

This project uses a repeatable support workflow:

1. Confirm the user’s symptom, impact, and timing.
2. Collect relevant system, disk, network, service, and event-log information.
3. Form a likely cause based on the evidence.
4. Apply the least disruptive supported fix.
5. Validate the outcome with the user and through a technical test.
6. Document actions taken, results, and follow-up steps.

## Security and Privacy

- Run scripts only on systems you own or are explicitly authorized to support.
- Do not commit locally generated files from `reports/`.
- Do not commit passwords, recovery keys, tokens, VPN profiles, `.rdp` files, `.ovpn` files, browser data, or production diagnostic exports.
- Sanitize computer names, usernames, serial numbers, MAC addresses, IP addresses, domains, Wi-Fi names, DNS servers, and organization-specific information before publishing examples.
- This project uses fictional examples and documentation-safe IP addresses where sample data is needed.

## Skills Demonstrated

- Windows 10/11 support fundamentals.
- PowerShell scripting and error handling.
- CIM-based inventory collection.
- Disk-space and uptime monitoring.
- Windows service troubleshooting.
- DNS and TCP/HTTPS connectivity validation.
- Basic Windows Event Log investigation.
- Documentation, ticket communication, and privacy-aware report handling.

## Documentation

- [Workstation setup and verification checklist](docs/workstation-setup.md)
- [Network troubleshooting runbook](docs/network-troubleshooting.md)
- [Common Windows troubleshooting playbooks](docs/troubleshooting-playbooks.md)
- [Fictional IT support ticket examples](docs/ticket-examples.md)
- [Sanitized system inventory sample output](sample-output/sanitized-system-inventory.txt)

## Disclaimer

This repository is a learning and portfolio project. It is not a replacement for an organization’s approved support procedures, endpoint-management tooling, security controls, change-management process, or incident-response process.
