# Day 05 – Storage Design & Integration (Portal + Scripts)

## 1. Objectives

- Design a secure general-purpose Storage Account (StorageV2).
- Enforce HTTPS-only access and disable anonymous blob access.
- Connect the Storage Account to Log Analytics using diagnostic settings.
- Integrate the Storage Account with an existing VM using Boot Diagnostics.
- Validate that boot diagnostic data is written into the Storage Account.

> Note: In this free-subscription lab, Storage diagnostic logs did not appear in Log Analytics, most likely due to subscription/preview limitations. The configuration steps are still valid for real environments.

---

## 2. Naming and Scope

- Subscription: current lab subscription
- Resource Group: **rg-day05-storage**
- Region: **West Europe**
- Storage Account: **stday05labweu**
- Container for tests: **logs-test**
- Existing VM for integration: **vmday04ub** (from Day 04)
- Existing Log Analytics Workspace: from Day 02 (replace with your real workspace ID in scripts)

---

## 3. Storage Design

### 3.1 Storage Account Configuration

- Type: **StorageV2 (General purpose v2)**
- Performance: **Standard**
- Redundancy: **LRS**
- Access tier (default): **Hot**
- Secure transfer required: **Enabled**
- Public access to blobs: **Disabled for anonymous access** (container level is Private)
- Network access: public endpoints allowed (no Private Endpoint in the free lab)

This design follows secure-by-default where possible:
- HTTPS-only enforced.
- No anonymous access to the container.
- Simple redundancy model (LRS) to keep cost low in the lab.

### 3.2 Container for Test Data

- Container name: **logs-test**
- Public access level: **Private (no anonymous access)**

Used to upload small test files and to validate that the Storage Account is functional.

---

## 4. Integration with Log Analytics (Diagnostic Settings)

### 4.1 Portal Configuration

On the Storage Account:

1. Go to **Monitoring → Diagnostic settings**.
2. Create a new diagnostic setting: **diag-storage-day05**.
3. Enable the **Transaction** log category.
4. Select **Send to Log Analytics workspace**.
5. Choose the existing workspace from Day 02.
6. Save the configuration.

### 4.2 Expected Log Flow

In a normal production subscription:

- The **Transaction** category sends Storage requests (read/write/delete) to the workspace.
- Data usually lands in **AzureDiagnostics** for modern Storage logging.
- Typical KQL query:

```kusto
AzureDiagnostics
| where ResourceType == "STORAGEACCOUNTS"
| where Category == "Transaction"
| sort by TimeGenerated desc
| take 50
In this lab, NSG logs were ingested successfully, but Storage Transaction logs did not appear, which is likely a platform or subscription constraint rather than a configuration error.

5. Integration with Compute (Boot Diagnostics)
5.1 Goal
Use the lab Storage Account stday05labweu as the custom Boot Diagnostics storage for VM vmday04ub:

Centralizes boot logs and screenshots in a controlled Storage Account.

Demonstrates a real integration scenario between Compute and Storage.

5.2 Portal Steps
On the VM vmday04ub:

Open the VM page in Azure Portal.

Go to Help → Boot diagnostics (new UI).

Change from:

Managed storage account (recommended)
to:

Custom storage account and select stday05labweu.

Save the configuration.

Restart the VM to generate fresh boot data.

5.3 Validation in Storage
In the Storage Account stday05labweu:

Open Containers.

Locate the container used for boot diagnostics.
A blob name similar to:

bootdiagnostics-vmday04ub-<guid>

Confirm that at least one file has been created (log or screenshot).

This confirms that:

Boot diagnostics is enabled with a custom Storage Account.

The VM successfully writes diagnostic data into the Storage Account.

6. CLI and PowerShell Coverage
For completeness and exam readiness:

CLI script creates:

Resource group

Storage Account

Private container

Diagnostic settings to Log Analytics

Boot diagnostics configuration for the VM

PowerShell script creates:

Resource group

Storage Account

Private container

Boot diagnostics configuration for the VM

Log Analytics integration can be managed by PowerShell as well, but the main demo for diagnostic settings in this lab is done via Azure CLI.

7. Key Takeaways
Storage Accounts are core integration points for diagnostics and VM boot logs.

Secure-by-default means HTTPS-only, private containers, and restricted access.

Diagnostic settings connect PaaS services to Log Analytics workspaces.

Boot Diagnostics is a very practical example of Compute ↔ Storage integration.

Free/lab subscriptions may not always reflect full logging behavior, but the design and configuration steps remain valid for real-world environments.

