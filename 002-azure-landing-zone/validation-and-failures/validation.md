# Validation

## 1. Policy enforcement

### 1.1. Expected behavior

- Resources deployed without required tags gets denied
- Resources deployed in not allowed locations gets denied
- Public IP creation in application zone gets denied

### 1.2. Validation

- Try to create resource without required tags stated in [0007-governance.md](..\architecture\architecture-decision-records\0007-governance.md)
- Try to create resource in location that's not stated in [0007-governance.md](..\architecture\architecture-decision-records\0007-governance.md)
- Try to create public IP in application zone

## 2. Identity structure

### 2.1. Expected behavior

- Responsibility groups defined in [0007-governance.md](..\architecture\architecture-decision-records\0007-governance.md) exists
- Role assignments for groups exists
- Scopes for groups exists 

### 2.2. Validation

- Responsibility groups exists with correct role assignments and scopes
- Create a test user account and test RBAC behavior?

## 3. Network boundaries

### 3.1. Expected behavior

- Hub VNet exists
- Spoke VNets exists
- Peering is configured

### 3.2. Validation

- Network Watchers confirms traffic flow?