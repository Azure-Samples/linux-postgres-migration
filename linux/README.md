# LINUX

```bash
# create a resource group for our azure resources
az group create --location eastus --name 240800-linux-postgres

# deploy the postgres.bicep using az cli
az deployment group create \
    --resource-group 240800-linux-postgres \
    --template-file linux/vm.bicep
```

## empty resource group
```bash
az deployment group create \
    --resource-group 240800-linux-postgres \
    --mode complete \
    --template-file linux/empty.bicep
```