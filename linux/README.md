# LINUX

## create a resource group for our azure resources
```bash
az group create --name 240800-linux-postgres --location westus2 
```

## deploy the postgres.bicep using az cli
```bash
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