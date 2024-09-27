# LINUX POSTGRES

## Get the currently logged-in user and the VM ID

```bash
USER_ID=$(az ad signed-in-user show --query id --output tsv)
VM_ID=$(az vm show --resource-group 240900-linux-postgres --name vm-1 --query id --output tsv)
```

## Assign the 'Virtual Machine Administrator Login' role to the user for the VM

```bash
az role assignment create \
    --assignee $USER_ID \
    --scope $VM_ID \
    --role "Virtual Machine Administrator Login"
```

## connect to azure virtual machine using the az ssh command

```bash
az ssh vm --resource-group 240900-linux-postgres --name vm-1
```

## install psql, and go (golang) on the virtual machine

```bash
sudo apt-get update
sudo apt-get install -y postgresql-client golang-go
```

## confirm the version of psql
    
```bash
psql --version
```

## install the azure cli

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

## login using the system assigned managed identity

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

## connect to the postgres server using bash and psql

### run the following commands on your local machine

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

## Clone the repository on your remote machine

```bash
git clone https://github.com/asw101/tt-go.git
```

## Change to the application directory

```bash
cd tt-go/
```

## Run the application

```bash
cd app/
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
  app:sql      sets up the environment for connecting to a PostgreSQL database
  app:token    gets a token using `azidentity.NewDefaultAzureCredential`
```

## connect to the psql server using go

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

## resources
- https://learn.microsoft.com/en-us/entra/identity/devices/howto-vm-sign-in-azure-ad-linux
- https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-connect-with-managed-identity
