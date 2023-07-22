
@allowed(['dev', 'stage', 'test', 'prod'])
@description('Specifies the environment to provision resources')
param env string = 'dev'


param location string = resourceGroup().location // Location for all resources
param webAppName string = uniqueString(resourceGroup().id)
param sku string = 'B1'

var appServicePlanName = toLower('AppServicePlan-${webAppName}')
var webSiteName = toLower('wapp-${webAppName}')


resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
  kind: 'linux'
  tags:{
    purpose: 'education'
    environment: env
  }
}


resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  identity:{
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOTNETCORE|7.0'
    }
  }
  tags:{
    purpose: 'education'
    environment: env
  }
}

output PrincipalId string = appService.identity.principalId
