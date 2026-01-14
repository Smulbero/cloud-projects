# 5. Subnet level Network Security Groups

Date: 2025-12-31

## Status

Accepted

## Context

Traffic control must be consistent, auditable and scalabe. Network Interface Card (NIC) level network security rules increase complexity and inconsistency.

## Decision

Apply network security rules at subnet level for group of resources instead of invidual NICs.

## Consequences

- Security rules are centralized and easier to manage
- Adding new workloads to subnets don't require new network security rules
- Changes to subnet level NSGs affect all workloads within the subnet
