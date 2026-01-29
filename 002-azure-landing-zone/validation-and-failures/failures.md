# Failures

## 1. VNet peering removed or misconfigured

### 1.1. Expected behavior

- Spoke networks may be isolated from hub
- Services in hub network may be unavailable

## 2. RBAC misconfigured

### 2.1. Expected behavior

- Users may have incorrect permissions to interract with intended resources
- Users may be able interract with unintended resources

## 3. Policies misconfigured

### 3.1. Expected behavior

- Resources could be created without proper tags
- Resources could be deployd in not allowed locations
- Application zone resources could be exposed to internet via public IP address