# Windows Network Troubleshooting Runbook

A practical, evidence-based workflow for diagnosing common Windows connectivity issues in an authorized support environment.

## Scope and Safety

Use this runbook only on systems you own or are authorized to support.

- Confirm the user’s symptom, impacted application or service, device location, network type, and time the issue started.
- Check whether the issue affects one user, multiple users, one location, or the wider organization.
- Avoid changing IP, DNS, proxy, VPN, firewall, or security settings until you have identified the likely fault domain and obtained required approval.
- Never publish real IP addresses, hostnames, Wi-Fi names, VPN details, DNS servers, or diagnostic output from an organization.
- Escalate suspected security incidents, outages affecting multiple users, or infrastructure failures through approved procedures.

## Rapid Triage

Ask these questions before beginning technical checks:

1. What exactly is not working: all internet access, one website, a business application, a network share, printing, VPN, or remote desktop?
2. When did the problem begin, and did anything change before it began?
3. Does the problem occur on another network, another device, or for another user?
4. Is the device connected by Ethernet, Wi-Fi, cellular, or VPN?
5. Are there visible error messages? Record the exact wording if possible.
6. Is the issue urgent because it blocks a critical business task?

## Troubleshooting Decision Tree

```text
User reports a network-related issue
|
+-- Is the device physically connected?
|   |
|   +-- No --> Check cable, dock, Wi-Fi status, airplane mode, and adapter state.
|   |
|   +-- Yes --> Continue.
|
+-- Does the device have a valid IP address, gateway, and DNS configuration?
|   |
|   +-- No --> Investigate adapter, Wi-Fi authentication, DHCP, VLAN, or VPN configuration.
|   |
|   +-- Yes --> Continue.
|
+-- Can the device reach its default gateway?
|   |
|   +-- No --> Likely local network, Wi-Fi, cable, adapter, VLAN, or gateway issue.
|   |
|   +-- Yes --> Continue.
|
+-- Can the device reach a known public IP address?
|   |
|   +-- No --> Investigate routing, firewall, proxy, ISP, VPN, or broader network outage.
|   |
|   +-- Yes --> Continue.
|
+-- Can the device resolve a DNS name?
|   |
|   +-- No --> Investigate DNS server assignment, DNS client service, VPN DNS behavior, or name records.
|   |
|   +-- Yes --> Continue.
|
+-- Can the required service and port be reached?
    |
    +-- No --> Check service availability, firewall rules, proxy requirements, VPN access, route, and port availability.
    |
    +-- Yes --> Investigate the application, user account, permissions, browser settings, or service-side errors.
```

## Collect Initial Evidence

Run these read-only commands in PowerShell. Sanitize output before adding anything to a ticket outside the approved support system.

```powershell
# Show usable interfaces, IP addresses, gateways, and DNS servers.
Get-NetIPConfiguration

# Show adapter state and link speed.
Get-NetAdapter

# Show the current Windows network profile.
Get-NetConnectionProfile

# Show the routing table.
Get-NetRoute

# Test the configured DNS name.
Resolve-DnsName -Name www.microsoft.com

# Test IP-level reachability to a known public address.
Test-Connection -ComputerName 1.1.1.1 -Count 4

# Test DNS name resolution and outbound HTTPS connectivity.
Test-NetConnection -ComputerName www.microsoft.com -Port 443 -InformationLevel Detailed
```

`Get-NetIPConfiguration` returns usable interfaces, IP addresses, and DNS server configuration. `Resolve-DnsName` performs a DNS query, while `Test-NetConnection` can provide TCP-port and connection diagnostics.

## Common Scenarios

### No Network Connection

**Symptoms**

- No network icon connection, “No internet,” disconnected Ethernet, or unavailable Wi-Fi.
- Device cannot reach the gateway, public IP addresses, or DNS names.

**Checks**

1. Confirm Ethernet cable, dock, Wi-Fi switch, and airplane-mode state.
2. Run `Get-NetAdapter` and confirm the expected adapter is not disabled.
3. Run `Get-NetIPConfiguration` and verify an address, gateway, and DNS server are present.
4. Look for an automatic private IP address in the `169.254.x.x` range, which can indicate that the device did not obtain normal DHCP configuration.
5. Test the default gateway shown in the configuration:

   ```powershell
   Test-Connection -ComputerName <default-gateway-IP> -Count 4
   ```

6. Compare with a known-good device on the same network if approved.
7. Escalate if multiple users, devices, or locations are affected.

**Possible next actions**

- Reconnect the cable or Wi-Fi network.
- Restart the approved network adapter or restart the workstation if appropriate.
- Reauthenticate to the approved wireless network.
- Escalate DHCP, VLAN, switch-port, wireless-access-point, or gateway issues to the network team.

### Internet Works by IP but Not by Name

**Symptoms**

- A public IP address responds, but websites or applications that use names fail.
- `Test-Connection 1.1.1.1` succeeds, while `Resolve-DnsName www.microsoft.com` fails.

**Likely fault domain**

DNS name resolution, DNS server configuration, DNS Client service, VPN DNS behavior, or a missing/incorrect DNS record.

**Checks**

```powershell
Get-NetIPConfiguration
Get-Service -Name Dnscache
Resolve-DnsName -Name www.microsoft.com
```

**Possible next actions**

- Verify that the device received the organization-approved DNS servers.
- Confirm the DNS Client service is running.
- If on VPN, confirm whether the required internal DNS servers and DNS suffixes are assigned by the approved VPN profile.
- Compare results with a known-good authorized device.
- Escalate DNS server, record, split-DNS, or VPN-profile issues rather than manually changing production DNS settings without approval.

### DNS Works but a Website or Application Fails

**Symptoms**

- The hostname resolves successfully, but a browser or application cannot connect.
- Other websites may work normally.

**Checks**

```powershell
Resolve-DnsName -Name <service-name>
Test-NetConnection -ComputerName <service-name> -Port 443 -InformationLevel Detailed
```

Replace `<service-name>` only with the approved service hostname. Use the actual application port only when it is documented and authorized.

**Possible causes**

- Service outage or maintenance.
- Required TCP port blocked by a firewall, proxy, VPN policy, or network path.
- Incorrect proxy configuration.
- Application authentication, permissions, certificate, or browser problem.
- Service is reachable but the user lacks access.

**Next actions**

- Check the organization’s status page or incident channel.
- Test the same service from another approved device or network.
- Compare results for another authorized user.
- Escalate to the application, network, identity, or security team with sanitized evidence.

### VPN Connects but Internal Resources Fail

**Symptoms**

- The VPN client reports connected, but internal websites, network shares, remote desktop, printers, or internal DNS names do not work.

**Checks**

1. Confirm the VPN client shows a current connected state.
2. Verify whether the issue affects every internal resource or only one.
3. Run `Get-NetIPConfiguration` before and after VPN connection, if permitted, and compare DNS servers, gateways, and active adapters.
4. Resolve an approved internal hostname:

   ```powershell
   Resolve-DnsName -Name <approved-internal-hostname>
   ```

5. Test the required service port:

   ```powershell
   Test-NetConnection -ComputerName <approved-internal-hostname> -Port <approved-port>
   ```

6. Review approved VPN client logs or error messages without copying sensitive configuration details into public documentation.
7. Test whether another authorized user has the same issue.

**Possible causes**

- VPN authentication or certificate issue.
- Incorrect VPN profile or expired configuration.
- Internal DNS not applied through the tunnel.
- Split-tunnel or route configuration issue.
- Firewall or conditional-access policy.
- Internal application outage or missing user authorization.

**Escalate when**

- Multiple VPN users are affected.
- The user is repeatedly prompted for credentials or multi-factor authentication fails.
- VPN configuration, certificates, routes, or security policy need to change.
- The issue may involve unauthorized access, account compromise, or a security-control failure.

### Network Share or Printer Is Unavailable

**Symptoms**

- A mapped drive, shared folder, or network printer cannot be reached.
- Internet access may still work normally.

**Checks**

```powershell
Resolve-DnsName -Name <approved-server-name>
Test-NetConnection -ComputerName <approved-server-name> -Port 445
```

For a network share, port 445 is commonly associated with SMB. A successful TCP test does not confirm the user has permission to access the share.

**Possible causes**

- Name resolution failure.
- VPN not connected or route unavailable.
- File server or print server outage.
- Firewall filtering.
- Expired credentials, account lockout, or missing permissions.
- Printer queue, driver, or spooler issue.

**Next actions**

- Confirm VPN status for remote users.
- Verify the user is authorized for the share or printer.
- Check for known service outages.
- Escalate permission changes to the resource owner or identity team.
- Escalate server, network, or printing infrastructure faults to the responsible team.

## Command Reference

| Goal | PowerShell command | What it helps determine |
|---|---|---|
| View network configuration | `Get-NetIPConfiguration` | Active interfaces, addresses, default gateways, and DNS servers |
| View adapter status | `Get-NetAdapter` | Whether an adapter is enabled, connected, and reporting link speed |
| View routes | `Get-NetRoute` | Whether a suitable route exists to a destination |
| Test a host by IP | `Test-Connection -ComputerName <IP> -Count 4` | Basic IP-level reachability; ICMP may be blocked even when a service is available |
| Resolve a name | `Resolve-DnsName -Name <hostname>` | Whether DNS returns records for a hostname |
| Test a TCP service | `Test-NetConnection -ComputerName <hostname> -Port <port>` | Whether a TCP path to a required host and port is reachable |
| Trace a route | `tracert -d <IP-or-hostname>` | The path toward a destination; use `-d` to avoid DNS lookups during the trace |
| View current connections | `Get-NetTCPConnection` | Current local and remote TCP connection properties |

## Documentation Template

Use this format for a support ticket or work note. Keep sensitive IP addresses, internal hostnames, and configuration details inside the organization’s approved ticketing system—not in this public repository.

```text
Issue:
User unable to access [approved service] while working from [office/remote location].

Impact:
[Describe the user-visible impact and whether other users are affected.]

Evidence collected:
- Adapter status: [connected/disconnected]
- IP configuration: [valid/invalid/needs escalation]
- Gateway test: [pass/fail/not tested]
- DNS resolution: [pass/fail]
- Service port test: [pass/fail]
- VPN status: [connected/not connected/not applicable]

Actions taken:
[Document only approved, least-disruptive actions.]

Result:
[Resolved, partially resolved, or escalated.]

Escalation details:
[Team, ticket number, sanitized evidence, and required follow-up.]
```

## Escalation Triggers

Escalate through approved procedures when:

- More than one user, device, site, or critical service is affected.
- The issue involves firewall, proxy, VPN, routing, DNS-server, VLAN, wireless, or switch configuration changes.
- You suspect malware, credential compromise, unauthorized access, or a security-policy issue.
- The required fix needs administrator rights, a privileged account, or a change outside your authorized scope.
- Basic endpoint checks are healthy but the service, network, or identity issue persists.
- You need to modify a production configuration, and no approved change process exists.
