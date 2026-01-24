# 5. Connectivity model

Date: 2026-01-23

## Status

Accepted

## Context

Centralized networking is needed to allow scalability, security and traffic control. This pattern will support enterprise scale.

## Decision

- Hub-and-spoke network topology will be used
- Shared networking services will reside inside the Connectivity resource group
- Other VNets will be peered with the hub
- Internet egress will be centralized

## Consequences

- Increased complexity initially, but high architectural clarity
- Networking pattern scales well without redesign