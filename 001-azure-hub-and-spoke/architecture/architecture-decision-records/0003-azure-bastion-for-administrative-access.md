# 3. Azure Bastion for administrative access

Date: 2025-12-31

## Status

Accepted

## Context

Administrative access to workloads is required, but exposing management ports (SSH/RDP) to the public internet increase attack surface.

## Decision

Use Azure Bastion in the central hub network to provide secure access to workloads in spoke networks over transport layer security (TLS) from Azure portal.

## Consequences

- Administrative access is centralized and logged
- Workloads don't need public IPs, agents or special claint software
- Reduced operational overhead compared to jump server
- Additional cost is incurred and deticated subnet is required