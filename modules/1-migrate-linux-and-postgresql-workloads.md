# Module 1: Migrate Linux and PostgreSQL workloads

## Introduction 

In this Learning Path, you'll be guided through a series of modules that enable you to migrate an existing workload from an on-premises or cloud environment to Azure. It covers the migration of the compute to an Azure Virtual Machine and the data to Azure Database for PostgreSQL. The application is a cloud-agnostic sample application that is a stand-in for any real-world application prepared for migration to the cloud. You explore the value of shifting from a self-hosted environment, such as from a self-managed database to a fully managed database offering and from bare-metal compute to cloud-hosted virtual machines with the benefit of a full suite of security and identity controls provided by Azure, such as Microsoft Entra ID. You'll also explore the benefits of managing resources in the cloud from a cost and performance perspective. You'll learn how to precisely calculate and manage costs before and after deployment, as well as how to optimize performance from both a compute and a data perspective. 

## Our workload 

Our workload is a cloud-agnostic application written in Go and/or Python that works with data inside PostgreSQL. 

Our data is an open dataset that enables you to explore the power of our Postgres platform and related extensions. 

Though this application could easily be run within a container, the stakeholders have not chosen to do so at this stage. Therefore, building a container, deploying to a container platform, or using container orchestration are out of scope at this stage, but this might be a logical future step. 

The application and its associated data are provided for you in the GitHub repository associated with this Learning Path. You'll learn how to prepare your application and export your data to reach a similar state to this sample application, or even use it as a template for a green-field deployment. 

## What is the value of migrating this workload? 

As we consider this migration effort, you may wonder about the benefits of migrating this workload to the cloud. There are many, but some of the value propositions include:

*Security and compliance.* When you bring compute and data workloads to the cloud, they benefit from increased security capabilities. Virtual Machines in Azure benefit from a vast array of security and compliance features, including firewalls, vnets, JIT, encryption, RBAC, and confidential computing. Azure Database for PostgreSQL supports many similar features as well, such as [encryption with customer-managed keys](/azure/postgresql/flexible-server/concepts-data-encryption), [compliance certifications](/azure/postgresql/flexible-server/concepts-compliance), and support for [Microsoft Defender for Cloud](/azure/postgresql/flexible-server/concepts-security#microsoft-defender-for-cloud-support).  

*Secure connections between your Virtual Machines and Databases.* As we integrate these two services, it is critical that they can connect to each other in a secure manner that reduces the risk of data loss. [Microsoft Entra ID authentication](/azure/postgresql/flexible-server/concepts-azure-ad-authentication) enables you to connect to your Azure Database for PostgreSQL without traditional passwords, but instead using Entra ID identities for both your application workload (Managed Identity) as well as users and administrators via their Entra ID user accounts. This mitigates the risk of long-lived credentials being compromised and allowing bad actors to access your data. Entra ID, Managed Identities, and fine-grained Role-Based Access Control (RBAC) can enable your application workload to access data and manage resources in Azure securely, following the principle of least privilege. 

*Access to high-performance and cost-effective compute across multiple regions.* Whether you need cost-effective compute for test-dev or the most recent, highest performance, or largest compute types available in the cloud today, Azure has a broad selection of compute options for both [Virtual Machines](/azure/virtual-machines/sizes/overview) and [Azure Database for PostgreSQL](/azure/postgresql/flexible-server/concepts-compute), which can be scaled up and down as needed, and are available across [over 60 regions](https://azure.microsoft.com/explore/global-infrastructure/products-by-region) in Azure. Compute can be scaled vertically as well as horizontally, including via [database replicas](/azure/postgresql/flexible-server/concepts-read-replicas) and [distributed options](/azure/cosmos-db/postgresql/introduction) such as Azure Cosmos DB for PostgreSQL, a managed service for PostgreSQL extended with the Citus open source superpower of distributed tables. This compute is paired with some of the [fastest cloud storage options](/azure/virtual-machines/disks-types) to tailor your compute and storage I/O requirements to your workload. 

*Cost management and cost-effectiveness.* You can optimize for cost management and cost-effectiveness on both the Linux and PostgreSQL sides. When compared with on-prem solutions, the cost can often be significantly more tailored and appropriate for your situation. You can right-size your compute in comparison to an on-prem solution. You can also easily manage your entire fleet to optimize for only the compute and storage you need, and pay only for what you use in a utility billing model. Utility billing enables customers to handle periods of high demand without having to pay the cost of over-provisioning and allows migration to faster and more efficient generations of compute as they become available. 

*Day 2 operations.* Operations across the board become more efficient through automation, the ability to upgrade easily with potentially zero downtime, monitoring, security patching, backups, and disaster recovery. Additionally, you can manage your infrastructure end-to-end with industry-standard toolchains.

## Resources
- [Create a Free Azure account](https://azure.microsoft.com/free/)
- [How to Install the Azure CLI](/cli/azure/install-azure-cli)