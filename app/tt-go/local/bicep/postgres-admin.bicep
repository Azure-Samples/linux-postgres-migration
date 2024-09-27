param postgresName string
param principalName string
param principalId string
param principalType string = 'ServicePrincipal'

resource postgresAdministrator 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2022-12-01' = {
  name: '${postgresName}/${principalId}'
  properties: {
    principalName: principalName
    principalType: principalType
    tenantId: subscription().tenantId
  }
}
