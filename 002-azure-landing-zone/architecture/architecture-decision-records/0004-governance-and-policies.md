# 4. Governance and Policies

Date: 2026-01-23

## Status

Accepted

## Context

Governance is a core landing zone principle, but too restrictive policies may reduce projects intend, learning in early stages.

## Decision

- Policy scope is subscription while allowing override per resource group if needed
- Governance focuses on:
    - Mandatory tagging
    - Location restrictions
- Policies are applied in audit or deployIfNotExists mode by default
- Deny policies are not used to let deployment process be less hindered

## Consequences

- Deployments are not blocked by policies but violations are still visible
- Transition to deny policies is straightforward later