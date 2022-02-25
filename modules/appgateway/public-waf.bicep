//https://docs.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?tabs=bicep

param name string
param location string = resourceGroup().location
param tags object = {
  provisioner: 'bicep'
  source: 'github.com/rjfmachado/bicepregistry/appgateway/public-waf'
}
param identityProfile object = {
  type: 'SystemAssigned'
}
param zones array = [
  '1'
  '2'
  '3'
]

//param enableFips bool = false
//param enableHttp2 bool = true
// param globalConfiguration object = {
//   enableRequestBuffering: false
//   enableResponseBuffering: false
// }

param gatewayIPConfigurations array
param frontendIPConfigurations array
param frontendPorts array
param backendAddressPools array
param backendHttpSettingsCollection array
param httpListeners array
param requestRoutingRules array
param autoscaleConfiguration object = {
  minCapacity: 0
  maxCapacity: 10
}
param sku object = {
  name: 'Standard_v2'
  tier: 'Standard_v2'
}
param sslCertificates array = []
param probes array = []

resource appgateway 'Microsoft.Network/applicationGateways@2021-05-01' = {
  name: name
  location: location
  tags: tags
  identity: identityProfile
  zones: zones
  properties: {
    //enableFips: enableFips
    //enableHttp2: enableHttp2
    // sslCertificates: null
    // probes: null
    autoscaleConfiguration: autoscaleConfiguration
    sku: sku
    sslCertificates: sslCertificates
    probes: probes
    gatewayIPConfigurations: gatewayIPConfigurations
    frontendIPConfigurations: frontendIPConfigurations
    frontendPorts: frontendPorts
    backendAddressPools: backendAddressPools
    backendHttpSettingsCollection: backendHttpSettingsCollection
    httpListeners: httpListeners
    requestRoutingRules: requestRoutingRules
    //globalConfiguration: globalConfiguration
  }
}
