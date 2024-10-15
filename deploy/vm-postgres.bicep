param location string = resourceGroup().location
param deployPostgres bool = true
param deployVm bool = true
param deployStorage bool = false
param sshKey string = ''

// The below is a sample ssh key we use if no sshKey is provided
// so that we can deploy easily without needing to provide it as
// a mandatory option. Because it is only to enable us to deploy
// we delete it immediately after deployment using cloud-init and
// customDataNoKey.

var keyData = sshKey != ''
  ? sshKey
  : 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3gkRpKwprN00sT7yekr0xO0F+uTllDua02puhu1v0zGu3aENvUsygBHJiTy+flgrO2q3mY9F5/D67+WHDeSpr5s71UtnbzMxTams89qmo+raTm+IqjzdNujaWf0/pbT6JUkQq0fR0BfIvg3/7NTXhlzjmCOP2EpD91LzN6b5jAm/5hXr0V5mcpERo8kk2GWxjKmwmDOV+huH1DIFDpMxT3WzR2qvZp1DZbNSYmKkrite3FHlPGLXA1I3bRQT+iTj8vRGpxOPSiMdPK4RNMEZVXSGQ3OZbSl2FBCbd/tdJ1idKo8/ZCkHxdh9/em28/yfPUK0D164shgiEdIkdOQJv'

var customDataNoKey = '''
#cloud-config
runcmd:
  - rm /home/azureuser/.ssh/authorized_keys
'''

var customData = sshKey != ''
  ? ''
  : customDataNoKey

var rand = substring(uniqueString(resourceGroup().id), 0, 6)
var virtualNetworkName = '${resourceGroup().name}-vnet'
var managedIdentityName = '${resourceGroup().name}-identity'
var nsgName = '${resourceGroup().name}-nsg'
var asgName = '${resourceGroup().name}-asg-app'
var vmName = 'vm-1'
var postgresName = 'postgres-${rand}'
var storageAccountName = 'storage${rand}'
var addressPrefix = '10.0.0.0/16'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: managedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(subscription().id, managedIdentity.id, 'Reader')
  properties: {
    // Reader role definition ID
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
    principalId: virtualMachine.outputs.systemAssignedMIPrincipalId
    principalType: 'ServicePrincipal'
  }
}

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.4.0' = if (deployVm) {
  name: 'virtualNetworkDeployment'
  params: {
    // Required parameters
    addressPrefixes: [
      cidrSubnet(addressPrefix, 16, 0)
    ]
    name: virtualNetworkName
    subnets: [
      {
        name: 'az-subnet-x-001'
        addressPrefix: cidrSubnet(addressPrefix, 24, 0)
        networkSecurityGroupResourceId: networkSecurityGroup.outputs.resourceId
      }
    ]
    // Non-required parameters
    location: location
  }
}

module networkSecurityGroup 'br/public:avm/res/network/network-security-group:0.4.0' = if (deployVm) {
  name: 'networkSecurityGroupDeployment'
  params: {
    name: nsgName
    location: location
    securityRules: [
      {
        name: 'AllowAnyCustom8080Inbound'
        properties: {
          access: 'Allow'
          // destinationAddressPrefix: '*'
          destinationApplicationSecurityGroupResourceIds: [
            applicationSecurityGroup.outputs.resourceId
          ]
          destinationPortRanges: [
            '8080'
          ]
          direction: 'Inbound'
          priority: 110
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

module applicationSecurityGroup 'br/public:avm/res/network/application-security-group:0.2.0' = if (deployVm) {
  name: 'applicationSecurityGroupDeployment'
  params: {
    // Required parameters
    name: asgName
    // Non-required parameters
    location: location
  }
}

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.6.0' = if (deployVm) {
  name: 'virtualMachineDeployment'
  params: {
    // Required parameters
    adminUsername: 'azureuser'
    imageReference: {
      publisher: 'canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
    name: vmName
    customData: customData
    encryptionAtHost: false
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            pipConfiguration: {
              name: '${vmName}-ip'
            }
            subnetResourceId: virtualNetwork.outputs.subnetResourceIds[0]
            applicationSecurityGroupResourceIds: [
              applicationSecurityGroup.outputs.resourceId
            ]
          }
        ]
        nicSuffix: '-nic-01'
      }
    ]
    osDisk: {
      caching: 'ReadWrite'
      diskSizeGB: 128
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Linux'
    vmSize: 'Standard_D2s_v4'
    zone: 0
    // Non-required parameters
    disablePasswordAuthentication: true
    location: location
    publicKeys: [
      {
        keyData: keyData
        path: '/home/azureuser/.ssh/authorized_keys'
      }
    ]
    managedIdentities: {
      systemAssigned: true
      userAssignedResourceIds: [
        managedIdentity.id
      ]
    }
    extensionAadJoinConfig: {
      enabled: true
    }
  }
}

module flexibleServer 'br/public:avm/res/db-for-postgre-sql/flexible-server:0.2.0' = if (deployPostgres) {
  name: 'flexibleServerDeployment'
  params: {
    // Required parameters
    name: postgresName
    skuName: 'Standard_D2ds_v4'
    tier: 'GeneralPurpose'
    // Non-required parameters
    administrators: [
      {
        objectId: managedIdentity.properties.principalId
        principalName: managedIdentityName
        principalType: 'ServicePrincipal'
      }
    ]
    storageSizeGB: 128
    geoRedundantBackup: 'Disabled'
    highAvailability: 'Disabled'
    location: location
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.13.3' = if (deployStorage){
  name: 'storageAccountDeployment'
  params: {
    // Required parameters
    name: storageAccountName
    // Non-required parameters
    kind: 'BlobStorage'
    location: location
    skuName: 'Standard_LRS'
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Allow'
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
    }
    roleAssignments: [
      {
        principalId: virtualMachine.outputs.systemAssignedMIPrincipalId
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
      }
      {
        principalId: managedIdentity.properties.principalId
        roleDefinitionIdOrName: 'Storage Blob Data Owner'
      }
    ]
  }
}
