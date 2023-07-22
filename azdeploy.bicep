targetScope = 'subscription'

@description('Specifies the location for resources.')
param region string = 'West Europe'

@allowed([ 'dev', 'stage', 'test', 'prod' ])
@description('Specifies the environment to provision resources')
param env string = 'dev'

@description('The default principal to have access to the Key Vault')
param demoUser string = '<create-your-demo-user-in-azure-ad>'

// run: az ad user show --id your-user-email
var me = '<you-user-object-id-in-AAD>'

resource rgDemoBicep 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${env}-demo-bicep'
  location: region
  tags: {
    environment: env
  }
}

module myAzureKeyVault './azure-keyvault.bicep' = {
  name: 'demo-key-vault-deployment'
  scope: rgDemoBicep
  params: {
    region: region
    env: env
    principalIds: [ demoUser, me, myWebApp.outputs.PrincipalId ]
  }
}

module myAppConfiguration './azure-app-configuration.bicep' = {
  scope: rgDemoBicep
  name: 'demo-app-configuration-deployment'
  params: {
    region: region
    env: env
    principals: [
      { id: demoUser, type: 'User' }
      { id: me, type: 'User' }
      { id: myWebApp.outputs.PrincipalId, type: 'ServicePrincipal' }
    ]
  }
}

module myWebApp './app-plan.bicep' = {
  name: 'my-web-app-demo'
  scope: rgDemoBicep
  params: {
    location: region
    webAppName: 'sample-demo'
    sku: 'B1'
    env: env
  }
}
