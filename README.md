# Linux and Postgres Migration

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/Azure-Samples/linux-postgres-migration)

## Introduction 

This module guides you through the migration of an existing workload from an on-premises or cloud environment to Azure. It covers the migration of the compute to an Azure virtual machine (VM) and the data to Azure Database for PostgreSQL. The application is a cloud-agnostic sample that's a stand-in for any real-world application that's prepared for migration to the cloud.

In this unit, you explore the value of making the following transitions with the benefit of a full suite of security and identity controls that Azure provides:

- Shifting from a self-hosted environment (such as from a self-managed database) to a fully managed database offering
- Shifting from bare-metal compute to cloud-hosted VMs

You also explore the benefits of managing resources in the cloud from a cost and performance perspective. And you learn how to precisely calculate and manage costs before and after deployment, along with how to optimize performance from both a compute and a data perspective.

[Browse Modules](./modules/README.md)

## Infrastructure (Bicep)

The [deploy/](./deploy) folder in this repo contains the infrastructure code for our deployment. In this folder you will see [vm-postgres.bicep](./deploy/vm-postgres.bicep) which is the Bicep template that deploys a Virtual Machine and a PostgreSQL database, and [empty.bicep](./deploy/empty.bicep) which is an empty Bicep template that can be used to delete the resources created by the [vm-postgres.bicep](./deploy/vm-postgres.bicep) file.

These Bicep templates use [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/).

## Data

The [app/data/](./app/data) folder in this repo contains data for our application workload. In this folder you will see [app/postgres/tailwind.sql](./app/data/postgres/tailwind.sql) which is the SQL file that will be imported into the PostgreSQL database. [app/data/images/](./app/data/images) contains images that will be uploaded to Azure Blob Storage.

## Application Code

Our application workload is Tailwind Traders (Go) which is available at: https://github.com/Azure-Samples/tailwind-traders-go
