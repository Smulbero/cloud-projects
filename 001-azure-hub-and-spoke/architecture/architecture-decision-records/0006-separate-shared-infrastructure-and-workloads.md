# 6. Separate shared infrastructure and workloads

Date: 2025-12-31

## Status

Accepted

## Context

Shared infrastructure and application workloads have different lifecycles, ownerships and access requirements. Managing them together increases risk of accidental changes and access management becomes complicated.

## Decision

Deploy shared infrastructure and application workloads into separate resource groups.

## Consequence

- Lifecycle management and ownership boundaries are clearer
- Access control is more precise
- Organizational management is more complex
- Awareness of cross resource group dependencies