# bicep

## find the id of the subscription
az account list | jq -c '.[]' | grep ca-aawislan-demo-test

## CloudNative
az account set --subscription 57039e18-c12e-4c87-a3e8-bf497991699d

## ca-aawislan-demo-test
az account set --subscription b9840869-8266-4fc8-8060-cfb339c08284

## aaron-cad
az account set --subscription 5428a634-bd96-4430-8ce2-058009e31188

## check subscription
az account show

## aad extension

```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vmName": {
            "type": "string"
        },
        "location": {
            "type": "string"
        }
    },
    "resources": [
        {
            "name": "[concat(parameters('vmName'),'/AADSSHLogin')]",
            "type": "Microsoft.Compute/virtualMachines/extensions",
            "location": "[parameters('location')]",
            "apiVersion": "2015-06-15",
            "properties": {
                "publisher": "Microsoft.Azure.ActiveDirectory",
                "type": "AADSSHLoginForLinux",
                "typeHandlerVersion": "1.0",
                "autoUpgradeMinorVersion": true
            }
        }
    ]
}
```

## az vpn rule

az network nsg rule create \
    --resource-group "240800-linux-postgres" \
    --nsg-name "240800-linux-postgres-nsg" \
    --direction 'Inbound' \
    --priority 2700 \
    --name "CorpNetPublic" \
    --source-address-prefix "CorpNetPublic" \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges '22' \
    --protocol '*'

## connect via ssh

az ssh vm --resource-group $RESOURCE_GROUP --name $VM_NAME

## ssh tunnel

az ssh vm -g $RESOURCE_GROUP -n $VM_NAME --local-user $USERNAME -- -L 5432:localhost:5432
