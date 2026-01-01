# Architecture

## Architecture Decision Records

Architectural design records are recorded to preserve context of architectural choices. These will be written in the format proposed in a
[blog post by Michael Nygard](http://thinkrelevance.com/blog/2011/11/15/documenting-architecture-decisions)

List of ADRs are in [architecture-decisions-records directory](.architecture-decision-records/).

### Tooling

[adr-tools](https://github.com/npryce/adr-tools) is used to help manage the decisions.

Use this tool only in the project folder

#### Initialization

`adr init ./architecture/architecture-decision-records`

#### Record new decision

`adr new 'Decision to record'`