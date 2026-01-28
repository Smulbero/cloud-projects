# 7. Governance

Date: 2026-01-26

## Status

Accepted

## Context

Responsibility model decided in ADR [0003-responsibility-model](0003-responsibility-model.md) and governance model decided in ADR [0004-governance-and-policies](0004-governance-and-policies.md) require role groups and applied policies.

## Decision

Platform and each resource group has their own groups for administration, contribution or operation purposes. Baseline policies are applied at subscription level while allowing stricter policies per resource group.

### Responsibility matrix

| Group 			| Scope 		| Permissions |
| -- 				| -- 			| -- |
| Platform admins 		| Subscription 		| Owner |
| Platform readers 		| Subscription 		| Reader |
| Identity admins 		| Identity RG 		| Contributor + Reader |
| Identity contributors 	| Identity RG 		| Contributor |
| Identity operators 		| Identity RG 		| Managed Identity Operator + Reader |
| Management admins 		| Management RG 	| Contributor + Reader |
| Management contributors 	| Management RG 	| Contributor |
| Connectivity admins 		| Connectivity RG 	| Contributor + Reader |
| Connectivity contributors 	| Connectivity RG 	| Network Contributor |
| Security admins 		| Security RG 		| Contributor + Reader |
| Security contributors 	| Security RG 		| Contributor |
| Security operators 		| Security RG 		| Security Admin (Entra ID role) |

### Policies

- Enforce resource tags on each resource:
	- CostCenter
	- Owner
	- DeployedMethod (Manual / IaC)
	- DeployedDate
- Deployed resources are allowed to be deployed in following regions:
	- North Europe
	- West Europe
- Enforce resource naming conventions where possible
- Deny public IP on application landing zones to prevent unnecessary internet exposure

## Consequences

- Each resource group has their own Entra ID role groups mapped to Azure RBAC roles
- Reduced risk of accidental misconfiguration across resources
- Policies enforce similarity in resources enabling easier troubleshooting, lifecycle management and filtering