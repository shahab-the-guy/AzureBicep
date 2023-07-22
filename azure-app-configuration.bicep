targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param region string

@allowed(['dev', 'stage', 'test', 'prod'])
@description('Specifies the environment to provision resources')
param env string = 'dev'

@description('Specifies the security principal that requires read access to this key vault')
param principals array

resource azureAppConfiguration 'Microsoft.AppConfiguration/configurationStores@2023-03-01'={
  name: 'apc-${env}-demo-bicep'
  location:region
  sku: {
    name: 'Free'
  }
  tags:{
    purpose: 'education'
    environment: env
  }
  properties:{
    disableLocalAuth: true
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource appConfigRoleWebApp 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = [for principal in principals:{
  name: principal.id
  scope: azureAppConfiguration
  properties: {
    principalId: principal.id
    principalType: principal.type
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '516239f1-63e1-4d78-a4de-a74fb236a071' )
  }
}]
