targetScope = 'resourceGroup'
param name string
param location string = resourceGroup().location
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/infra/virtualnetwork'
}
param zones array = [
  '1'
  '2'
  '3'
]
param sku object = {
  name: 'Standard'
  tier: 'Regional'
}
//param dnsSettings object = {}
param publicIPAddressVersion string = 'IPv4'
param publicIPAllocationMethod string = 'Static'

resource pip 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  zones: zones

  properties: {
    publicIPAddressVersion: publicIPAddressVersion
    publicIPAllocationMethod: publicIPAllocationMethod
  }
}

output id string = pip.id
output name string = pip.name
output ipaddress string = pip.properties.ipAddress
output properties object = pip.properties
