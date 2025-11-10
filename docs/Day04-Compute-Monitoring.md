# **Day 04 – Compute and Monitoring (AZ-305 Free Tier)**

## 🎯 Objectives
Design and deploy a secure compute resource (Virtual Machine) inside the existing governed network,  
enable centralized monitoring, and validate metric collection in Log Analytics.

---

## 🧩 Architectural Overview
| Component | Name | Purpose |
|------------|------|----------|
| Resource Group | `rg-day01-governance-weu` | Central governance scope |
| Virtual Network | `vnet-day03-secure-weu` | Secure segmented network |
| Subnet | `Frontend-Subnet` | Hosting zone for the test VM |
| NSG | `nsg-Frontend` | Enforces Zero-Trust inbound rules |
| Virtual Machine | `vm-day04-ubuntu-weu` | Compute node for testing and monitoring |
| Log Analytics Workspace | `log-day01-gov-weu` | Centralized monitoring and diagnostics |
## ⚙️ Implementation Steps (Azure Portal)

1. **Create the Virtual Machine**
   - Go to **Virtual Machines → + Create → Azure virtual machine**
   - Resource Group: `rg-day01-governance-weu`
   - Name: `vm-day04-ubuntu-weu`
   - Region: `West Europe`
   - Image: `Ubuntu Server 24.04 LTS - x64 Gen2`
   - Size: `Standard_B1s` (Free tier compatible)
   - Authentication type: `Password`
   - Disable Public IP (set to None)
   - Subnet: `Frontend-Subnet`
   - NSG: `nsg-Frontend`

2. **Configure Management**
   - Boot diagnostics: `On (managed storage account)`
   - Do not enable legacy LinuxDiagnostics extension
   - Keep all alert and application health monitoring options disabled for now

3. **Validation**
   - Ensure the VM is deployed successfully without Public IP
   - Confirm that the NIC effective security group = `nsg-Frontend`
## 🧩 Diagnostic Settings and Log Analytics Integration

1. **Enable Diagnostic Settings**
   - Open the VM → **Diagnostic settings → + Add diagnostic setting**
   - Name: `diag-vm-day04`
   - Enable: **Send all metrics to Log Analytics**
   - Destination: **log-day01-gov-weu**
   - Save the configuration

2. **Verify Data Ingestion**
   - Wait 10–15 minutes after enabling diagnostics
   - Open **Log Analytics workspace → Logs**
   - Run the following KQL query:

```kusto
AzureMetrics
| where TimeGenerated > ago(30m)
| where ResourceId contains "vm-day04-ubuntu-weu"
| summarize Count = count() by MetricName
| order by Count desc
Expected Result

Metrics such as BytesSentRate, BytesReceivedRate, PacketsSentRate, and PacketsReceivedRate should appear

This confirms the VM is correctly sending metrics to the workspace
## ✅ Outcome
- Secure VM successfully deployed inside the governed VNet.  
- Network isolation and NSG rules verified.  
- Diagnostics configured to send metrics to `log-day01-gov-weu`.  
- AzureMetrics table confirmed active and ingesting data.  
- Environment is now ready for **Day 05 – Storage Design & Integration**.

---

## 🔍 Useful KQL Queries

**Network Metrics Summary**
```kusto
AzureMetrics
| where TimeGenerated > ago(24h)
| where ResourceId contains "vm-day04-ubuntu-weu"
| summarize Count = count() by MetricName
| order by Count desc
Network Traffic Trend
AzureMetrics
| where TimeGenerated > ago(1h)
| where ResourceId contains "vm-day04-ubuntu-weu"
| where MetricName in ("BytesSentRate", "BytesReceivedRate")
| summarize AvgValue = avg(Total) by MetricName, bin(TimeGenerated, 5m)
| order by TimeGenerated asc

