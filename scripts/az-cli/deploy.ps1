# Deploy baseline monitoring (Log Analytics)

az group create `
  --name rg-az305-monitoring-weu `
  --location westeurope

az deployment group create `
  --resource-group rg-az305-monitoring-weu `
  --template-file infra/bicep/main.bicep
