# Linux and Postgres Migration Learning Path 

## Introduction 

In this Learning Path you will be guided through a series of modules that will enable you to migrate an existing workload from an on-premises or cloud environment to Azure. This will cover the migration of the compute to an Azure Virtual Machine and the data to Azure Database for PostgreSQL. The application will be a cloud agnostic sample application that is a stand-in for any real-world application prepared for migration to the cloud. You will explore the value shifting from a self-hosted environment, such as from a self-managed database to a fully-managed database offering, as well as from bare-metal compute to cloud-hosted virtual machines with the benefit of a full suite security and identity controls provided by Azure, such as Microsoft Entra ID. You will also explore the benefits of managing resources in the cloud from a cost and performance perspective. You will understand how to precisely calculate and manage costs prior to, and following deployment. Understand how to optimize performance from both a compute and data perspective. 

## Our Workload 

Our workload is a cloud agnostic application written in Go and/or Python that works with data inside of PostgreSQL. 

Our data is an open dataset that will enable you to explore the power of our Postgres platform and related extensions. 

Thought this application could easily be run within a container, the stakeholders have not chosen to do so at this stage. So building a container, and deploying to a container platform, or using container orchestration, are out of scope at this stage, but this may be a logical future step. 

The application, and its associated data, has been provided for you in the GitHub repository associated with this Learning Path. You will understand how to prepare your application and export your data to reach a similar state to this sample application, or even use it as a template for a green-field deployment.
