# Architectural design
- Deployment of hub-and-spoke network to act as gateway to workloads
- Use of Bastion instead of public IP and SSH/RDP connection
- Workloads don't use public IPs
- NSGs at subnet level
- Separate resource groups for workloads and infrastructure 