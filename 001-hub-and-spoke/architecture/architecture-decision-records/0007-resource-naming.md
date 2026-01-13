# 7. Resource Naming

Date: 2026-01-02

## Status

Accepted

## Context

As the number of resources increases, inconsistent naming makes it difficult to identify their purpose and environment. This complicates troubleshooting, automation, access control and cost analysis. A standardized naming convention is required to ensure consistency across all resources.

## Decision

Adopt a standardized resource naming convention based on Microsoft recommendations using the following pattern where applicable:

[resourceType]-[workload]-[environment]-[azureRegion]-[instanceNumber]

Example: `vm-webapp-prod-northeurope-01`

## Consequences

- Resources are easier to identify, search and manage
- Naming consistency improves readability and reduces ambiguity
- Some resources impose naming constraints that require deviation from the standard format
- Longer names may reduce readability and usability