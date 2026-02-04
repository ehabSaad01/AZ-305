// Secure-by-default baseline
// Creates Log Analytics Workspace for monitoring foundation

@description('Location for resources')
param location string = resourceGroup().location

@description('Log Analytics workspace name')
param workspaceName string = 'law-az305-baseline-weu'

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: workspaceName
  location: location
  properties: {
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}
