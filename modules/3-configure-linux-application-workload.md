# Module 3: Configure a Linux application workload​

## Introduction

In this module, you will:

- Configure a Linux application workload to connect to an Azure Database for PostgreSQL using a system-assigned managed identity.
- Connect to the [Azure Virtual Machine using the Azure CLI](/azure/virtual-machines/linux/quick-create-cli). 
- Install the necessary tools.
- Connect to the PostgreSQL server using `psql`.
- Clone the repository containing the sample application.
- Run the application and confirm it can connect to the PostgreSQL server using the managed identity.

## Get the Currently Logged-In User and the VM ID

```bash
USER_ID=$(az ad signed-in-user show --query id --output tsv)
VM_ID=$(az vm show --resource-group 240900-linux-postgres --name vm-1 --query id --output tsv)
```

## Assign the 'Virtual Machine Administrator Login' role to the user for the VM

You can read more about the Privileged role in Azure VMs on the [Azure built-in roles for Privileged](/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator).

```bash
az role assignment create \
    --assignee $USER_ID \
    --scope $VM_ID \
    --role "Virtual Machine Administrator Login"
```

## Connect to the Azure Virtual Machine Using the Azure CLI

```bash
az ssh vm --resource-group 240900-linux-postgres --name vm-1
```

## Install psql and Go (golang) on the Virtual Machine

Update the package list.

```bash
sudo apt-get update
```

Install the PostgreSQL client and Go (golang) on the Virtual Machine.

```bash
sudo apt-get install -y postgresql-client golang-go
```

## Confirm the version of psql
    
```bash
psql --version
```

## Install the Azure CLI on the Virtual Machine

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## Log in to the Azure CLI using the System Assigned Managed Identity

```bash
az login --identity
```

You should see output as follows:

```
$ az login --identity
[
  {
    "environmentName": "AzureCloud",
    "homeTenantId": "b4c72be8-cae1-4584-be77-62b1e94ad0dc",
    "id": "57039e18-c12e-4c87-a3e8-bf497991699d",
    "isDefault": true,
    "managedByTenants": [],
    "name": "CloudNative",
    "state": "Enabled",
    "tenantId": "b4c72be8-cae1-4584-be77-62b1e94ad0dc",
    "user": {
      "assignedIdentityInfo": "MSI",
      "name": "systemAssignedIdentity",
      "type": "servicePrincipal"
    }
  }
]
```

## Connect to the PostgreSQL server using bash and psql

Run the following commands on the remote machine

```bash
MANAGED_IDENTITY_NAME=240900-linux-postgres-identity
export AZURE_CLIENT_ID=$(az identity show --resource-group 240900-linux-postgres --name $MANAGED_IDENTITY_NAME --query "clientId" -o tsv)
PG_NAME=$(az postgres flexible-server list --resource-group 240900-linux-postgres --query "[0].name" -o tsv)

# set psql environment variables
export PGHOST="${PG_NAME}.privatelink.postgres.database.azure.com"
export PGPASSWORD=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fossrdbms-aad.database.windows.net&client_id=${AZURE_CLIENT_ID}" -H Metadata:true | jq -r .access_token)
export PGUSER=$MANAGED_IDENTITY_NAME
export PGDATABASE=postgres

# login using psql
psql
```

Once connected you should see the below output. Type the `\q` command to exit.

```
$ psql
psql (16.4 (Ubuntu 16.4-0ubuntu0.24.04.2))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
Type "help" for help.

postgres=> \q
$ 
```

## Clone the sample application, Tailwind Traders (Go), to the machine

Run the following commands on the remote machine

```bash
git clone https://github.com/Azure-Samples/tailwind-traders-go.git
```

Change to the application directory

```bash
cd tailwind-traders-go/app/
```

Run the application

```bash
go run main.go
```

The output should be similar to:

```
$ go run main.go
go: downloading github.com/magefile/mage v1.15.0
go: downloading github.com/Azure/azure-sdk-for-go/sdk/azcore v1.14.0
go: downloading github.com/Azure/azure-sdk-for-go/sdk/azidentity v1.7.0
go: downloading github.com/Azure/azure-sdk-for-go/sdk/internal v1.10.0
go: downloading github.com/AzureAD/microsoft-authentication-library-for-go v1.2.2
go: downloading golang.org/x/crypto v0.26.0
go: downloading golang.org/x/net v0.28.0
go: downloading github.com/google/uuid v1.6.0
go: downloading github.com/pkg/browser v0.0.0-20240102092130-5ac0b6a4141c
go: downloading github.com/kylelemons/godebug v1.1.0
go: downloading github.com/golang-jwt/jwt/v5 v5.2.1
go: downloading golang.org/x/text v0.17.0
Targets:
  app:connectionString    outputs a connection string for the database from env vars
  app:ping                pings the database
  app:serve               runs a web server for our application
  app:tables              lists the tables in the database
  app:token               gets a token using `azidentity.NewDefaultAzureCredential`
```

## Connect to the PostgreSQL server using Tailwind Trader (Go)'s `app:token` target

```bash
MANAGED_IDENTITY_NAME=240900-linux-postgres-identity
export AZURE_CLIENT_ID=$(az identity show --resource-group 240900-linux-postgres --name $MANAGED_IDENTITY_NAME --query "clientId" -o tsv)
PG_NAME=$(az postgres flexible-server list --resource-group 240900-linux-postgres --query "[0].name" -o tsv)

# psql
export PGHOST="${PG_NAME}.privatelink.postgres.database.azure.com"
export PGPASSWORD=$(go run main.go app:token)
export PGUSER=$MANAGED_IDENTITY_NAME
export PGDATABASE=postgres

# login using psql
psql
```

## Quit psql and disconnect from the remote machine

Quit psql.

```bash
\q
```

Disconnect from the remote machine.

```bash
exit
```

## Resources
- [Sign in to a Linux virtual machine in Azure using Azure AD](/entra/identity/devices/howto-vm-sign-in-azure-ad-linux)
- [Connect to an Azure Database for PostgreSQL server using a managed identity](/azure/postgresql/single-server/how-to-connect-with-managed-identity)
- [Create a Linux virtual machine with the Azure CLI on Azure](/azure/virtual-machines/linux/quick-create-cli). 
- [Azure built-in roles for Privileged](/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator).