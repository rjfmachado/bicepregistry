targetScope = 'resourceGroup'

param name string
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/infra/dns'
}

param linkedVirtualNetworks array = [
  {
    id: ''
    registrationEnabled: false
  }
]

resource privatednszone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: name
}

resource linkPrivateDNSZoneAKSvnetPrivateAKS 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for vnet in linkedVirtualNetworks: if (!empty(linkedVirtualNetworks)) {
  name: guid(name, vnet.id)
  parent: privatednszone
  location: 'global'
  tags: tags
  properties: {
    registrationEnabled: vnet.registrationEnabled
    virtualNetwork: {
      id: vnet.id
    }
  }
}]
