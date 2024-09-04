# POSTGRES

## create a resource group for our azure resources
```bash
az group create --location eastus --name 240800-linux-postgres
```

## deploy the postgres.bicep using az cli
```bash
az deployment group create \
    --resource-group 240800-linux-postgres \
    --template-file postgres/postgres.bicep
```

## empty resource group
```bash
az deployment group create \
    --resource-group 240800-linux-postgres \
    --mode complete \
    --template-file postgres/empty.bicep
```
