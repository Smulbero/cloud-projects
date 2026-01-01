# 2. Hub-and-spoke network

Date: 2025-12-31

## Status

Accepted

## Context

Environment is intende to host multiple workloads while maintained separation between shared infrastucture and application workloads. Flat network topology doesn't scale well as number of workloads increase, has increased security risks and governance becomes more complicated.

## Decision

Use hub-and-spoke network toplogy where shared infrastructure is deployd in a central hub and application workloads are deployed into separate spoke networks connected via peering.

## Consequences

- Shared services can be centralized and reused by multiple workloads
- Network address planning and routing becomes harder
- Network security and routing policies can be applied consistently
- Design scales well as number of workloads and spoke networks increase