targetScope = 'resourceGroup'

param name string
param location string = 'westeurope'

param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/bicepregistry/acr/standard'
}

param sku object = {
  name: 'Standard'
}

resource acr 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: name
  sku: sku
  location: location
  tags: tags
  properties: {}
}

output name string = acr.name
output loginServer string = acr.properties.loginServer
output id string = acr.id
