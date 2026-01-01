# Bastion

## Problem
Public endpoints are security risk

## Why Bastion
- Entra ID integration
- Access from any device that can log into Azure portal
- Centralized logging
- Inbound ports are not exposed

## Trade-offs
- Additional cost
- Requires own subnet

## Rejected alternatives
- Jump server
    - Higher maintenance
    - Exposed attack surface