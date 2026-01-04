# 9. Secure Internet Access

Date: 2026-01-04

## Status

Accepted

## Context

Workloads require access to the public internet for updates, package downloads and external service dependencies. 

## Decision

Deploy Azure Firewall in the hub virtual network and route all egress and ingress traffic through the firewall.

## Consequences

- Centralized traffic control and logging
- Allow and deny traffic flows more precisely
- Additional costs
- Requires route table management