var rand = substring(uniqueString(resourceGroup().id), 0, 6)
var postgresName = 'postgres-${rand}'
var location = 'westus2'

module flexibleServer 'br/public:avm/res/db-for-postgre-sql/flexible-server:0.2.0' = {
  name: 'flexibleServerDeployment'
  params: {
    // Required parameters
    name: postgresName
    skuName: 'Standard_D2s_v3'
    tier: 'GeneralPurpose'
    // Non-required parameters
    // administrators: [
    //   {
    //     objectId: '<objectId>'
    //     principalName: '<principalName>'
    //     principalType: 'ServicePrincipal'
    //   }
    // ]
    geoRedundantBackup: 'Enabled'
    highAvailability: 'ZoneRedundant'
    location: location
  }
}
