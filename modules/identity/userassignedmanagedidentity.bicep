targetScope = 'resourceGroup'

param name string
param location string = resourceGroup().location
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/infra/identity'
}

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: name
  location: location
  tags: tags
}

output name string = uami.name
output id string = uami.id
output principalId string = uami.properties.principalId
output clientId string = uami.properties.clientId
output tenantId string = uami.properties.tenantId
