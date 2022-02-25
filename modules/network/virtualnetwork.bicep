targetScope = 'resourceGroup'
param name string = 'virtualnetwork'
param location string = resourceGroup().location
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/infra/virtualnetwork'
}
param addressSpacePrefixes array = [
  '10.0.0.0/16'
]
param dnsServers array = []

@minLength(1)
param subnetProfile array = [
  {
    name: 'aksnodepoolsystem'
    properties: {
      addressPrefix: '10.0.0.0/24'
    }
  }
  {
    name: 'aksnodepoolmonitoring'
    properties: {
      addressPrefix: '10.0.1.0/24'
    }
  }
  {
    name: 'aksnodepoolapps'
    properties: {
      addressPrefix: '10.0.2.0/24'
    }
  }
  {
    name: 'akssystempods'
    properties: {
      addressPrefix: '10.0.3.0/24'
      delegations: [
        {
          name: 'Microsoft.ContainerService/managedClusters'
          properties: {
            serviceName: 'Microsoft.ContainerService/managedClusters'
          }
        }
      ]
    }
  }
  {
    name: 'aksmonitoringpods'
    properties: {
      addressPrefix: '10.0.4.0/24'
      delegations: [
        {
          name: 'Microsoft.ContainerService/managedClusters'
          properties: {
            serviceName: 'Microsoft.ContainerService/managedClusters'
          }
        }
      ]
    }
  }
  {
    name: 'aksapppods'
    properties: {
      addressPrefix: '10.0.128.0/22'
      delegations: [
        {
          name: 'Microsoft.ContainerService/managedClusters'
          properties: {
            serviceName: 'Microsoft.ContainerService/managedClusters'
          }
        }
      ]
    }
  }
  {
    name: 'data'
    properties: {
      addressPrefixes: [
        '10.0.1.0/24'
      ]
      delegations: [
        {
          name: 'Microsoft.DBforPostgreSQL.flexibleServers'
          properties: {
            serviceName: 'Microsoft.DBforPostgreSQL/flexibleServers'
          }
        }
      ]
    }
  }
]

param ddosProtectionPlan string = ''

//==============================================================

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: addressSpacePrefixes
    }
    dhcpOptions: {
      dnsServers: dnsServers
    }
    ddosProtectionPlan: empty(ddosProtectionPlan) ? json('null') : {
      id: ddosProtectionPlan
    }
    subnets: subnetProfile
  }
}

output id string = virtualnetwork.id
output name string = virtualnetwork.name
output subnets array = virtualnetwork.properties.subnets
