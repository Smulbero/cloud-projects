# 2. Landing Zone Scope

Date: 2026-01-23

## Status

Accepted

## Context

The landing zone is intended for learning and reusability baseline. The design doesn't have to be large but must remain extensible as number or subscriptions and management groups increase without refactoring the structure. The design may contain some components that doesn't have immediate usage but they are there for demonstration purposes.

## Decision

The landing zone will be implemented with a single subscription, single environment and single department deployment. Management groups will not be used for logical separation, instead resource groups will be used. Resource groups will represent platform responsibilities, not environments. 

The design must support future promotion of:
- Resource group -> subscription
- Subscription -> management group

## Consequences

- Governance is applied at resource group level
- Some platform components may exist without immediate usage
- Scaling beyond the initial scope doesn't need refactoring