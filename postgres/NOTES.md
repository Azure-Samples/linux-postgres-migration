# POSTGRES NOTES

## deploy using avm via:

https://github.com/Azure/bicep-registry-modules/tree/main/avm/res/db-for-postgre-sql/flexible-server#example-1-using-only-defaults

## follow quickstart

https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-bicep?tabs=CLI

## explain and link to "why avm"

https://azure.github.io/Azure-Verified-Modules/concepts/what-why-how/

## original bicep parameters
```bicep
param administratorLoginPassword string
param location string = resourceGroup().location
param serverName string
param serverEdition string = 'GeneralPurpose'
param skuSizeGB int = 128
param dbInstanceType string = 'Standard_D4ds_v4'
param haMode string = 'ZoneRedundant'
param availabilityZone string = '1'
param version string = '12'
param virtualNetworkExternalId string = ''
param subnetName string = ''
param privateDnsZoneArmResourceId string = ''
```