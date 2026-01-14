# Project validation and failures

This directory contains functional and architectural validation for this project.

The goal of validation is to demonstrate that the architecture behaves as designed, regardless of whether the environment was deployed manually or via IaC tools.

Validation focuses on expected behavior based on architectural design, not on high availability or resiliency, unless they are part of the design.

## Scope

## validation.md

validation.md documents usage oriented validation scenarios, written as short narratives describing:
- Who or what does an action or interaction
- Expected behavior
- Validation criteria

Validation does not attempt to:
- Compare alternative solutions
- Justify architecture decisions
- Prove service level guarantees
- Replace other operational procedures such as service monitoring or service alerts 

## failures.md

failures.md documents expected system behavior during failure scenarios, written as short narratives describing:
- A failure condition
- Expected behavior

Failure scenarios are used to understand dependencies and system behavior during failure conditions. The following topics are intentionally out of scope unless they are addressed by the architecture:
- High availability or resiliency
- Probability or likelihood
- Disaster recovery options