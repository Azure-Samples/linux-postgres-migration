# LINUX & POSTGRES

## create a resource group for our azure resources
```bash
az group create \
    --name 240900-linux-postgres \
    --location westus2
```

## vm & postgres
```bash
az deployment group create \
    --resource-group 240900-linux-postgres \
    --template-file deploy/vm-postgres.bicep
```

## vm only
```bash
az deployment group create \
    --resource-group 240900-linux-postgres \
    --template-file deploy/vm-postgres.bicep \
    --parameters deployPostgres=false
```

## postgres only
```bash
az deployment group create \
    --resource-group 240900-linux-postgres \
    --template-file deploy/vm-postgres.bicep \
    --parameters deployVm=false
```

## empty.bicep
```bash
az deployment group create \
    --resource-group 240900-linux-postgres \
    --template-file deploy/empty.bicep \
    --mode complete
```

## delete a resource group
```bash
az group delete \
    --name 240900-linux-postgres
```
