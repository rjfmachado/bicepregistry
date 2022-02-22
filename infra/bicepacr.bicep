targetScope = 'subscription'

param name string
param location string = 'westeurope'
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/bicepregistry'
}

param principalId string
param roleDefinitionIdOrName string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: name
  location: location
  tags: tags
}

module acr 'acr.bicep' = {
  scope: rg
  name: name
  params: {
    name: name
    location: location
    tags: tags
    sku: {
      name: 'Standard'
    }
    principalId: principalId
    roleDefinitionIdOrName: roleDefinitionIdOrName
  }
}

output loginServer string = acr.outputs.loginServer
