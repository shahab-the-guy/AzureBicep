targetScope = 'resourceGroup'

@description('Specifies the location for resources.')
param region string

@allowed(['dev', 'stage', 'test', 'prod'])
@description('Specifies the environment to provision resources')
param env string = 'dev'


@description('Specifies the security principal that requires read access to this key vault')
param principalIds array

var tenantId = subscription().tenantId

resource demoKeyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: take('kv-${env}-demo-bicep',24)
  location: region
  properties: {
    sku: {
      family: 'A'
      name: 'standard' 
    }
    tenantId: tenantId
    accessPolicies: [for principalId in principalIds:{
        objectId: principalId
        permissions:{
          secrets:['Get', 'List', 'Set']
        }
        tenantId:tenantId
      }]
    enabledForDeployment:true
  }
  tags:{
    purpose: 'education'
    environment: env
  }
}
