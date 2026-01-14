# Hub-and-spoke network

## Project Overview
Implementing a secure, scalable Azure network foundation that isolates workloads while centralizing administrative access and security controls. 

Goals of this project
- Separation of different workloads and infrastructure
- Workloads are able to communicate to different virtual networks via central hub
- Workloads don't have public IPs and cannot be accessed from external source
- Workload administrative access goes through Bastion
- Egress network traffic flows through firewall