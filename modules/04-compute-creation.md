# Create Infrastructure (Compute)

## Introduction

In the following sections we will guide you through the creation of the compute resources that will host your application within Azure.

There are multiple methods to deploy infrastructure in Azure, including the Azure Portal, Azure CLI, and Infrastructure as Code templates including Bicep and Terraform.

In this module we will show you how to deploy a pre-configured [Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/overview?tabs=bicep) template that encapsulates the compute resources required for your application.

The key resources you will deploy are:

- Virtual Machine (VM) running Linux (Ubuntu ...).
- Azure Database for Postgres running Postgres ...
- A Managed Identity to enable secure access from the VM to the database.
- Role Base Access Controls (RBAC) including roles to access the database as an administrator, and more restrictive roles for the application itself.
- A Virtual Network for both the VM and database.

As this is a test/dev workload, and we are looking to keep things both cost-effective and performant, we have chosen the following configuration for you:

The VM SKU is a ... with N cores, and ... Solid State Disk (SSD). This provides ... IOPs.

The database SKU is a ... with N cores, and ... Solid State Disk (SSD). This provides ... IOPs.

At the completion of the module you will likely delete these resources to save cost. However, you can also turn both the VM and database off when not in use to save compute cost, and pay only for the storage used. This workload can also be scaled up as needed.

The Bicep in this module utitlies [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/) which is "an initiative to consolidate and set the standards for what a good Infrastructure-as-Code module looks like". These modules are maintained by Microsoft and encapsulate many best practices for deploying resources in Azure. 

## Azure Subscription and Azure CLI 

If you don't have an Azure subscription, create a [free account](https://azure.microsoft.com/free/) before you begin.

This module requires Azure CLI version 2.0.30 or later. Run `az --version` to find the version. If you need to install or upgrade, see [Install Azure CLI](/cli/azure/install-azure-cli).

## Log in to Azure using the CLI

In order to run commands in Azure using the CLI, you need to log in first. Log in using the `az login` command.

## Create a resource group

A resource group is a container for related resources. All resources must be placed in a resource group. The [az group create](/cli/azure/group) command creates a resource group.

```bash
az group create \
    --name 240800-linux-postgres \
    --location westus2
```

## Deploy the Bicep template using the Azure CLI

Bicep is a domain-specific language (DSL) that uses declarative syntax to deploy Azure resources. In a Bicep file, you define the infrastructure you want to deploy to Azure, and then use that file throughout the development lifecycle to repeatedly deploy your infrastructure. Your resources are deployed in a consistent manner.

The bicep file we are using to deploy the compute resources is located at [linux/vm.bicep](/linux/vm.bicep). It contains a Virtual Machine, a Virtual Network, a Managed Identity, a Network Security Group for the VM.

Open your terminal and run the following az CLI command to deploy the bicep template.

```bash
az deployment group create \
    --resource-group 240800-linux-postgres \
    --template-file linux/vm.bicep
```
