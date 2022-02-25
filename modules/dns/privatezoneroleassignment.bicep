targetScope = 'resourceGroup'

param name string
param roleAssignments array = [
  {
    principalId: ''
    roleDefinitionId: ''
  }
]

resource privatednszone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = {
  name: name
}

resource roleAssignmentsPrivateDNS 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = [for assignment in roleAssignments: if (!empty(roleAssignments)) {
  name: guid(assignment.principalId, assignment.roleDefinitionId, privatednszone.id)
  scope: privatednszone
  properties: {
    principalId: assignment.principalId
    roleDefinitionId: assignment.roleDefinitionId
    principalType: 'ServicePrincipal'
  }
}]
