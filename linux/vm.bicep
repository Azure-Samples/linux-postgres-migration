var rand = substring(uniqueString(resourceGroup().id), 0, 6)
var vmName = 'vm${rand}'
var location = 'westus2'
param sshKey string = ''
var keyData = sshKey != '' ? sshKey : 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC3gkRpKwprN00sT7yekr0xO0F+uTllDua02puhu1v0zGu3aENvUsygBHJiTy+flgrO2q3mY9F5/D67+WHDeSpr5s71UtnbzMxTams89qmo+raTm+IqjzdNujaWf0/pbT6JUkQq0fR0BfIvg3/7NTXhlzjmCOP2EpD91LzN6b5jAm/5hXr0V5mcpERo8kk2GWxjKmwmDOV+huH1DIFDpMxT3WzR2qvZp1DZbNSYmKkrite3FHlPGLXA1I3bRQT+iTj8vRGpxOPSiMdPK4RNMEZVXSGQ3OZbSl2FBCbd/tdJ1idKo8/ZCkHxdh9/em28/yfPUK0D164shgiEdIkdOQJv'

module virtualMachine 'br/public:avm/res/compute/virtual-machine:0.6.0' = {
  name: 'virtualMachineDeployment'
  params: {
    // Required parameters
    adminUsername: 'azureuser'
    imageReference: {
      offer: '0001-com-ubuntu-server-jammy'
      publisher: 'Canonical'
      sku: '22_04-lts-gen2'
      version: 'latest'
    }
    name: vmName
    nicConfigurations: [
      {
        ipConfigurations: [
          {
            name: 'ipconfig01'
            pipConfiguration: {
              name: 'pip-01'
            }
            subnetResourceId: '<subnetResourceId>'
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
    vmSize: 'Standard_D2s_v3'
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
  }
}
