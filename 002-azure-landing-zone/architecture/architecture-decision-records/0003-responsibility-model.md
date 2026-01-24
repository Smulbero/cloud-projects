# 3. Responsibility Model

Date: 2026-01-23

## Status

Accepted

## Context

Ownership boundaries must be clear even within a single subscription to simulate enterprise scale and have separation of services.

## Decision

The landing zone will use responsibility based resource groups:
- Identity
    - Identity related services, e.g. Entra ID Domain Services
- Connectivity
    - Shared networking services, e.g. Azure Bastion, Azure Firewall
- Management 
    - Monitoring, logging, dashboards
- Security
    - Security related tools and services, e.g. Microsoft Sentinel
- Workload deployment
    - Workload specific resources, e.g. deparment vm's or app services

## Consequences

- Workloads do not own shared services
- RBAC can be applied consistently
- Resource groups can be turned into subscriptions without redesign