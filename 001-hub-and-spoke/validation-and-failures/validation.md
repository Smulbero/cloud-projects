# Validation

## 1. Spoke-to-spoke communication

**Expected behavior**

- Workloads in different spoke networks can communicate via hub routing

**Validation**

- ICMP (ping) succeeds between workloads in different spoke networks

## 2. Administrative access goes through Azure Bastion

**Expected behavior**
- Administrative access to workload is possible only through Azure Bastion

**Validation**
- Connection succeeds

## 3. Internet access from workload

**Expected behavior**
- Workload can access allowed internet destinations
- Egress traffic flows through Azure Firewall

**Validation**
- HTTP/HTTPS succeeds only for allowed destinations
- Traceroute shows firewall as next hop