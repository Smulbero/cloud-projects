# 4. No public IPs

Date: 2025-12-31

## Status

Accepted

## Context

Workloads don't require direct access from the public internet. Assigning public IPs would expose them to external threats.

## Decision

Don't assign public IPs to workloads. Administrative access goes through Azure Bastion.

## Consequences

- Reduced attack surface from external threats
- Access from external network is restricted to Azure Bastion