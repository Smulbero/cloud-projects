# Troubleshooting during deployment

During deployment and validation of the hub-and-spoke topology, some connectivity issues were encountered that impacted the validation process.

## ICMP failed between networks

ICMP (ping) was initially planned as primary method to validate connectivity between networks, but it is often blocked by:
- Network security controls
- Firewalls
- Network devices and appliances

As a result, ICMP failure doesn't reliably validate routing or connectivity and therefore it shouldn't be used as primary validation tool.

### TCP based connectivity test

Connectivity between workloads should be validated using TCP based tests, which better reflects application traffic and firewall behavior.

Tools:
- Windows: `Test-NetConnection`
- Linux: `nc` (netcat)

Known port as a listening port on the workload should be used:
- SSH
- RDP
- Application specific port

Successful TCP connectivity is considered sufficient proof of functional network connectivity.

### Troubleshooting approach

Troubleshooting process involved:
- Inspection of effective routes
- Review network security rules
- Platform diagnostics (Network Watcher)
    - NSG diagnostics
    - Next hop
    - Connection troubleshoot