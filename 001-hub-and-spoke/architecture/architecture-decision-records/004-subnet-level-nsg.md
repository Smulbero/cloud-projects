# Subnet level NSGs

## Problem
Inconsistent security enforcement

## Why subnet level NSGs
- Governance becomes easier
- Less rule duplication
- Traffic boundries become clearer

## Trade-offs
- Changes affect all subnet resources
- Good subnet grouping for resources required

## Rejected alternatives
- Use of Application Security Groups
    - Additional complexity
    - Better suited for larger enviroments
- Azure Firewall
    - Additional cost
    - Complexity not needed for this project
