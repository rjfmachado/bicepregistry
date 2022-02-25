targetScope = 'resourceGroup'

param name string
param roleAssignments array = [
  {
    principalId: ''
    roleDefinitionId: ''
  }
]

resource virtualnetwork 'Microsoft.Network/virtualNetworks@2021-03-01' existing = {
  name: name
}

resource roleAssignmentsPrivateDNS 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for assignment in roleAssignments: if (!empty(roleAssignments)) {
  name: guid(assignment.principalId, assignment.roleDefinitionId, virtualnetwork.id)
  scope: virtualnetwork
  properties: {
    principalId: assignment.principalId
    roleDefinitionId: assignment.roleDefinitionId
    principalType: 'ServicePrincipal'
  }
}]
