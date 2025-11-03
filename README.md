
AZ-305 Program
Practical-first track to design secure, governable Azure solutions aligned to AZ-305. Files are production-ready and organized for repeatable automation.

Structure
mathematica
Copy code
AZ-305/
  scripts/
    Governance-Identity-Baseline_cli.sh
    Governance-Identity-Baseline_cli.ps1
  docs/
    Governance-Identity-Baseline.md
  README.md
Workflow
Portal → validate.

CLI/PowerShell → automate.

GitHub → version control and reviews.

Day 01 — Governance & Identity Baseline
Management Group hierarchy.

Allowed Locations policy (West Europe).

RBAC on least privilege.

Log Analytics Workspace and Subscription Activity Logs export.

Execute
Bash: ./scripts/Governance-Identity-Baseline_cli.sh

PowerShell: pwsh ./scripts/Governance-Identity-Baseline_cli.ps1

Monitoring
Use the KQL snippets in docs/Governance-Identity-Baseline.md to verify data flow.
