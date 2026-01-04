# Failures

## 1. Route table removed from spoke subnet

**Expected behavior**

- Workloads regain direct internet access, bypassing centralized egress controls

## 2. Next hop misconfigured in user defined routes

**Expected behavior**

- Egress traffic from one or many spoke subnets fail

## 3. Azure Firewall unavailable

**Expected behavior**

- Egress traffic fails for affected workloads

## 4. Configured DNS servers unavailable or misconfigured

**Expected behavior**

- Name resolution fails

## 5. VNet peering removed or misconfigured

**Expected behavior**

- Spoke network isolated from hub
- Services in hub network unavailable

## 6. Azure Network Manager misconfigured

**Expected behavior**

- Unexpected topology changes affecting connectivity or isolation

## 7. Azure Bastion unavailable

**Expected behavior**

- Workload administrative access lost

## 8. Hub virtual network removed (resource deletion)

**Expected behavior**

- Services in hub network deleted
- VNet peerings between hub and spoke networks automatically removed
- Spoke workloads continue to operate but are isolated