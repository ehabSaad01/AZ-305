# **Day 03 – Secure Network Design (AZ-305 Free Tier)**

## 🎯 Objectives
Design a secure, segmented virtual network following the **Zero Trust** and **secure-by-default** principles.  
The network will host compute and monitoring resources in later days.

---

## 🧩 Architectural Concept
- Create a **Virtual Network (VNet)** with a wide address space (`10.0.0.0/16`) to allow scalable subnetting.
- Define three subnets:
  - `Mgmt-Subnet` for management tools (e.g., Azure Bastion)
  - `Frontend-Subnet` for public-facing workloads
  - `Backend-Subnet` for internal application and database tiers
- Apply dedicated **Network Security Groups (NSGs)** to each subnet.
- Enable **Diagnostic Settings** to send NSG logs and metrics to the centralized **Log Analytics Workspace**.
## ⚙️ Implementation Steps (Azure Portal)

1. **Create the Virtual Network**
   - Navigate to **Virtual Networks → + Create**
   - Resource Group: `rg-day01-governance-weu`
   - Name: `vnet-day03-secure-weu`
   - Region: `West Europe`
   - IPv4 address space: `10.0.0.0/16`
   - Add the following subnets:
     - `Mgmt-Subnet` → `10.0.1.0/24`
     - `Frontend-Subnet` → `10.0.2.0/24`
     - `Backend-Subnet` → `10.0.3.0/24`

2. **Create NSGs**
   - Go to **Network Security Groups → + Create**
   - Create:
     - `nsg-Frontend`
     - `nsg-Backend`
     - `nsg-Mgmt`
   - Associate each NSG with its respective subnet.

3. **Configure NSG Rules**
   - **nsg-Frontend**
     - Allow inbound HTTP (TCP/80) from *Internet*
     - Allow inbound HTTPS (TCP/443) from *Internet*
     - Deny all other inbound traffic
   - **nsg-Backend**
     - Allow inbound SQL (TCP/1433) from `10.0.2.0/24`
     - Deny all other inbound traffic
   - **nsg-Mgmt**
     - Allow inbound 443 from `AzureCloud` (for Bastion)
     - Deny all other inbound traffic
4. **Enable Diagnostics and Flow Logs**
   - Open each NSG → **Diagnostic settings → + Add diagnostic setting**
   - Name: `diag-nsg-[name]`
   - Enable:
     - `NetworkSecurityGroupEvent`
     - `NetworkSecurityGroupRuleCounter`
     - `NetworkFlowLog`
   - Destination: **Send to Log Analytics workspace**
   - Select: `log-day01-gov-weu`
   - Save the configuration for all three NSGs.

---

## 🔍 Verification (KQL)

To confirm that the NSG logs are correctly sent to the workspace:

```kusto
AzureDiagnostics
| where TimeGenerated > ago(24h)
| where Category in ("NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter", "NetworkFlowLog")
| summarize Count = count() by Category
| order by Category asc
If the query returns no results, ensure the flow logs are enabled and wait for traffic to occur.

✅ Outcome
Secure VNet architecture created.

Segmented subnets and NSGs deployed.

Diagnostic logs centralized in log-day01-gov-weu.

Environment ready for Compute Deployment in Day 04.

