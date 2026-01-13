# 8. Network Addressing

Date: 2026-01-02

## Status

Accepted

## Context

The environment is expected to be multi region and have multiple workloads for different use cases. Defining IP addressing strategy is critical in order for network expansion not becoming prone to errors or risking overlapping address spaces. Address space must be planned to support scalability and isolation.

## Decision

- Allocate /16 address range per Azure region
- Within each region, allocate /20 address range per virtual network
- Within each virtual network, allocate subnets sized according to functional requirements

The following tables illustrate the strategy using North Europe as example.

### Region addressing

| Region        | Address range |
| :-            | :-            |
| North Europe  | 10.10.0.0/16  |
| West Europe   | 10.20.0.0/16  |
| South UK      | 10.30.0.0/16  |
| Reserved      | Remaining     |

### VNet addressing

| VNet                               | Address range | Role   | Purpose              |
| :-                                 | :-            | :-     | :-                   |
| vnet-hub-northeurope-01            | 10.10.0.0/20  | Hub    | Gateway, Bastion     |
| vnet-[department-1]-northeurope-01 | 10.10.16.0/20 | Spoke  | Department workloads |
| vnet-[department-2]-northeurope-01 | 10.10.32.0/20 | Spoke  | Department workloads |

### Subnet addressing

#### Hub vnet (10.10.0.0/20)

| Subnet                | IP range              |
| :-                    | :-                    |
| GatewaySubnet         | 10.10.0.0/26          |
| AzureBastionSubnet    | 10.10.1.0/26          |
| Reserved              | Remaining             |

#### Deparment 1 vnet (10.10.16.0/20)

| Subnet                | IP range              |
| :-                    | :-                    |
| Workload              | 10.10.16.0/24         |
| Reserved              | Remaining             |

## Consequences

- Clear boundaries of different environments
- Address spaces support future expansions without redesigning existing ranges
- Larger address spaces may result in unsued IPs