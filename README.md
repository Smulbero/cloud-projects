# cloud-projects

This repository contains cloud related projects that I have designed and implemented as part of my ongoing learning and skill development.

Each project focuses on building practical infrastructure and services while documenting architectural decisions and implementations. The goal of each project is to understand why specific architectural decisions were made and how they affect scalability, security and workflows, not only how something is built.

## Purpose

This repository serves as my personal playground and project log for hands-on cloud work. It is used to explore cloud architecture patterns, validate implementation and document ideas, decisions and outcomes. Projects may be revisited over time.

## Project approach

Each project folows a similar structure:
- Define the problem being solved
- Research possible solutions
- Design solution, including assumptions and constraints
- Document architecture and decision
- Solution implementation
- Validation of expected behavior and failures
- Recreation the solution using Infrastructure as Code tools

## Documentation

Documentation is treated as part of thinking process and solution, not something done afterwards. Design decisions are recorded using lightweight architecture decision records to capture context, decision and consequences.

## Project structure

Each project contained in its own directory and typically includes following files.
- README.md <br>
    Project overview and goals.
- architecture/ <br>
    Architecture documentation and diagrams
- architecture/decision-records/ <br>
    Architecture decision records
- manual-deployment/ <br>
    Notes, summaries, configurations(?)
- iac-deployment/ <br>
    Way to deploy using IaC tools

## Scope

Projects vary in size and complexity. Focus is on learning architectural design and implementation rather than complete production readiness. Some designs might favor simplicity over complexity.