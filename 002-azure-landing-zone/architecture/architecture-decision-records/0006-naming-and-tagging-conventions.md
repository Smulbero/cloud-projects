# 6. Naming and Tagging conventions

Date: 2026-01-24

## Status

Accepted

## Context

As number of resources increase, operational tasks such as cost management, access control, troubleshooting and/or lifecycle management become more difficult without consistent naming and taggin. Standardized resource naming and tagging conventions will keep resources organized and their boundaries clear.

## Decision

### Resource naming

Adopt a standardized resource naming convention based on Microsoft recommendations using the following pattern where applicable:

[resourceType]-[workload]-[environment]-[azureRegion]-[instanceNumber]

Example: `vm-webapp-prod-northeurope-01`

### Resource tags

Each resource must include the following tags:
- CostCenter
- Owner
- DeployedMethod (Manual / IaC)
- DeployedDate

## Consequences

- Resource purpose, ownership, environment and boundaries are clear
- Resources deployed manually or via code are distinguishable
- Age of resources is known, enabling easier lifecycle management and filtering