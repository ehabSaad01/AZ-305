# ADR 0001: Monitoring First (Log Analytics Baseline)

## Status
Accepted

## Context
All production architectures require centralized logging and analytics to enable:
- Security monitoring and threat detection
- Operational visibility and troubleshooting
- Auditability and compliance evidence
Without a monitoring baseline, later platform services (network, compute, data) become harder to operate and secure.

## Decision
We will deploy an Azure Log Analytics Workspace as the first foundational component in this repository.
- A single workspace provides a central landing zone for logs/metrics.
- Access will be resource-permission-based (secure-by-default).
- Retention starts at 30 days and will be adjusted per environment needs.

## Consequences
- All subsequent labs will assume a workspace exists.
- Azure Monitor, Sentinel (optional), and diagnostic settings will target this workspace.
- We can standardize alerts, queries, and workbooks across the architecture.

## References
- Azure Monitor / Log Analytics Workspace
- Microsoft AZ-305: Design logging and auditing solutions
