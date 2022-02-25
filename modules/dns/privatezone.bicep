targetScope = 'resourceGroup'

param name string
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/infra/dns'
}

resource privatednszone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: name
  location: 'global'
  tags: tags
}

output name string = privatednszone.name
output id string = privatednszone.id
