# Module 3: Configure a Linux application workload​

In this unit, you will:

- Configure a Linux application workload to connect to Azure Database for PostgreSQL by using a system-assigned managed identity.
- Connect to the [Azure virtual machine by using the Azure CLI][docs-url-1].
- Install the necessary tools.
- Connect to the PostgreSQL server by using **psql**.
- Clone the repository that contains the sample application.
- Run the application and confirm that it can connect to the PostgreSQL server by using the managed identity.

## Connect to the Azure virtual machine by using the Azure CLI

1. Get the currently logged-in user and the VM ID

    ```bash
    USER_ID=$(az ad signed-in-user show --query id --output tsv)
    VM_ID=$(az vm show --resource-group 240900-linux-postgres --name vm-1 --query id --output tsv)
    ```

    **Alert:** This may take a couple minutes to complete.

1. Assign the Virtual Machine Administrator Login role to the user for the VM

    ```bash
    az role assignment create \
        --assignee $USER_ID \
        --scope $VM_ID \
        --role "Virtual Machine Administrator Login"
    ```

    You can read more about privileged roles for Azure VMs in [Azure built-in roles for Privileged][docs-url-2].

1. Connect to the virtual machine

    ```bash
    az ssh vm --resource-group 240900-linux-postgres --name vm-1
    ```

## Install psql and Go on the virtual machine

1. Update the package list:

    ```bash
    sudo apt-get update
    ```

1. Install the PostgreSQL client and Go (Golang) on the virtual machine:

    ```bash
    sudo apt-get install -y postgresql-client golang-go
    ```

1. Confirm the version of psql

    ```bash
    psql --version
    ```

<!-- ## Install the Azure CLI on the virtual machine

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
``` -->

## Connect to the PostgreSQL server by using Bash and psql

1. Sign in to the Azure CLI by using the system-assigned managed identity:

    ```bash
    az login --identity
    ```

    The output will be similar to the following:

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

1. Connect to the PostgreSQL server:

    ```bash
    MANAGED_IDENTITY_NAME=240900-linux-postgres-identity
    export AZURE_CLIENT_ID=$(az identity show --resource-group 240900-linux-postgres --name $MANAGED_IDENTITY_NAME --query "clientId" -o tsv)
    PG_NAME=$(az postgres flexible-server list --resource-group 240900-linux-postgres --query "[0].name" -o tsv)

    # Set psql environment variables
    export PGHOST="${PG_NAME}.privatelink.postgres.database.azure.com"
    export PGPASSWORD=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fossrdbms-aad.database.windows.net&client_id=${AZURE_CLIENT_ID}" -H Metadata:true | jq -r .access_token)
    export PGUSER=$MANAGED_IDENTITY_NAME
    export PGDATABASE=postgres

    # Log in by using psql
    psql
    ```

    After you're connected, the following output appears.

    ```
    $ psql
    psql (16.4 (Ubuntu 16.4-0ubuntu0.24.04.2))
    SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off)
    Type "help" for help.

    postgres=> \q
    $ 
    ```

1. Enter the `\q` command to exit.

## Clone the sample application

1. Clone the sample application, Tailwind Traders (Go). Run the following commands on the remote machine:

    ```bash
    git clone https://github.com/Azure-Samples/tailwind-traders-go.git
    ```

1. Change to the application directory:

    ```bash
    cd tailwind-traders-go/app/
    ```

1. Run the application:

    ```bash
    go run main.go
    ```

    The output will be similar to the following:

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

## PostgreSQL server connection using the Tailwind Traders (Go) app:token target

1. Sign in using psql:

    ```bash
    MANAGED_IDENTITY_NAME=240900-linux-postgres-identity
    export AZURE_CLIENT_ID=$(az identity show --resource-group 240900-linux-postgres --name $MANAGED_IDENTITY_NAME --query "clientId" -o tsv)
    PG_NAME=$(az postgres flexible-server list --resource-group 240900-linux-postgres --query "[0].name" -o tsv)

    # psql
    export PGHOST="${PG_NAME}.privatelink.postgres.database.azure.com"
    export PGPASSWORD=$(go run main.go app:token)
    export PGUSER=$MANAGED_IDENTITY_NAME
    export PGDATABASE=postgres

    # Sign in by using psql
    psql
    ```

1. Quit **psql**:

    ```bash
    \q
    ```

1. Disconnect from the remote machine:

    ```bash
    exit
    ```

## Resources

- [Sign in to a Linux virtual machine in Azure by using Microsoft Entra ID and OpenSSH][docs-url-3]
- [Connect to an Azure Database for PostgreSQL server by using a managed identity][docs-url-4]
- [Create a Linux virtual machine with the Azure CLI on Azure][docs-url-1]
- [Azure built-in roles for Privileged][docs-url-2]

[docs-alt-1]: /azure/virtual-machines/linux/quick-create-cli
[docs-url-1]: https://learn.microsoft.com/azure/virtual-machines/linux/quick-create-cli
[docs-alt-2]: /azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator
[docs-url-2]: https://learn.microsoft.com/azure/role-based-access-control/built-in-roles/privileged#role-based-access-control-administrator
[docs-alt-3]: /entra/identity/devices/howto-vm-sign-in-azure-ad-linux
[docs-url-3]: https://learn.microsoft.com/entra/identity/devices/howto-vm-sign-in-azure-ad-linux
[docs-alt-4]: /azure/postgresql/single-server/how-to-connect-with-managed-identity
[docs-url-4]: https://learn.microsoft.com/azure/postgresql/single-server/how-to-connect-with-managed-identity
