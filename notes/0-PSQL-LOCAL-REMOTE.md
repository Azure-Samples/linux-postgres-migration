## connect to the postgres server using managed identity (local and remote)

### run the following commands on your local machine

```bash
PG_NAME=$(az postgres flexible-server list --resource-group 240900-linux-postgres --query "[0].name" -o tsv)
IDENTITY_NAME=240900-linux-postgres-identity
IDENTITY_CLIENT_ID=$(az identity show --resource-group 240900-linux-postgres --name $IDENTITY_NAME --query "clientId" -o tsv)

# this is what you will paste into the remote terminal
echo "export PG_NAME=$PG_NAME"
echo "export IDENTITY_NAME=$IDENTITY_NAME"
echo "export IDENTITY_CLIENT_ID=$IDENTITY_CLIENT_ID"
```

You should see output similar to:

```
export PG_NAME=postgres-ji2dbe
export IDENTITY_NAME=240900-linux-postgres-identity
export IDENTITY_CLIENT_ID=1fbc69dc-9a16-4727-a728-36f6d8d82f13
```

### run the following commands on your remote machine

```bash
# config
export PG_NAME=postgres-ji2dbe
export IDENTITY_NAME=240900-linux-postgres-identity
export IDENTITY_CLIENT_ID=1fbc69dc-9a16-4727-a728-36f6d8d82f13

# set psql environment variables
export PGHOST="${PG_NAME}.privatelink.postgres.database.azure.com"
export PGPASSWORD=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fossrdbms-aad.database.windows.net&client_id=${IDENTITY_CLIENT_ID}" -H Metadata:true | jq -r .access_token)
export PGUSER=$IDENTITY_NAME
export PGDATABASE=postgres

# login using psql
psql -h $PGHOST
```