# Linux Learning Path outline 

 

## Introducing the application workload (readme: cloud and application agnostic) 

Small sample application that is a stand-in for any real-world app that runs on Linux compute and talks to a Postgres database 

This app is starting pre-container orchestration (NOT migration from on-prem K8s) 

Going from some kind of self-hosted database to a fully manage db offering and exploring the value 

 

===Linux==== 

 

### Why of the migration 

Getting value from the managed database and value 

Security and compliance 

DB connection strings and secrets 

Role-based access controls	 

Availability of compute 

Cost management and cost-effectiveness (on both the Linux and the Postgres side) and compare with on-prem 

Right size compute vs on prem 

 

## Creation of Compute  

Breakdown of the compute: selection of SKUs, cores, attached disks, matching IO between VM and SSDs (deploying a much smaller and leaner deployment; most cost-effective but still performant) 

This kind of app, has this kind of data 

Explain the data and dataset 

How to deploy the compute with Bicep and explain why  

 

## Provisioning a Linux virtual machine in Microsoft Azure 

Who? Aaron* 

Bicep? Azure Verified Modules? 

 

## Build and Deploy the Application workload 

See if we can mirror a similar structure to the MEAN Learn module [Build and run a web application with the MEAN stack on an Azure Linux virtual machine](https://learn.microsoft.com/en-us/training/modules/build-a-web-app-with-mean-on-a-linux-vm/ ) 

We need a sample application. Aaron* could write a very basic one in Go and/or Python as a stop-gap. 

Rather than composed from snippets it should be pulled from an Azure-Samples GitHub repo (likely Azure-Sample/linux-postgres-migration ). 

Just show _something_ running. 

Persistent that is running as a daemon  

Admin tools running (from the same VM? Avoid x-plat issues, e.g. Windows?) 

 

## Configure the managed identity 

https://learn.microsoft.com/en-us/training/modules/implement-managed-identities/  

Incorporate the above module. Ensure we discuss System Assigned vs User Assigned managed identity. 

This may cover the creation of the user assigned managed identity, but this is likely to have been pre-created, along with the VM, during provisioning with Bicep. 

 

## Webapp that fails gracefully 

Confident they’ve deployed the webapp successfully 

Highlight Azure Front Door as a solution for providing TLS termination. Also discuss TLS termination via the Caddy Web Server (https://github.com/caddyserver/caddy ) and/or certmagic (https://github.com/caddyserver/certmagic ), which could be baked into the sample. 

Docs to reference:  

https://learn.microsoft.com/en-us/azure/frontdoor/end-to-end-tls?pivots=front-door-standard-premium 

https://learn.microsoft.com/en-us/azure/frontdoor/create-front-door-bicep?tabs=CLI 

https://learn.microsoft.com/en-us/azure/frontdoor/front-door-waf 

 

===Postgres=== 

## Deploy the Database compute 

Bicep? Azure Verified Modules? 

Because it’s in Bicep we’re making decisions for you: 

Storage we’re using 

VM or database SKU 

As a developer as a test dev exercise (not for actual production) 

Refer back to cost effectiveness exercise specifcally for storage 

Performance tuning of database (for _even more_ cost effectiveness) deep dive into: 

Link to docs or other content on performance tuning 

 

## Import the data 

Discuss the nature of the dataset. 

Why this dataset? Are there others? 

Where did it come from, in our scenario (simulating a “migration”) 

Sample dataset (is there a standard sample dataset we typically use?) 

Consider https://github.com/lerocha/chinook-database 

Chinook was used by PG Chat, GitHub Copilot Extension in VS Code (https://www.youtube.com/watch?v=eMlOzf-0RAE ). 

SSH’d into the VM, don’t need to worry about their local machineDisc. Acts as a “jump box”, enables to use private VNET if necessary (probably not in this case). Optionally talk about trade-offs, security, compliance, not having data on local developer/dba machines, etc. 

Other tools we might want to use, such as GUI tools via VS Code, Datagrip, Postico, etc? We could discuss options that makes this feel more friendly to more data oriented customers vs a developer oriented “hello world”. Perhaps there are docs that cover various tools. 

 

### Get an administrator access to the database 

Lean on Entra ID docs for Postgres 

https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-configure-sign-in-azure-ad-authentication 

Look at Aaron’s automation code for accessing Postgres and auto-configuring Firewall rules and Entra ID admin. 

Show how you could access it from outside the VM, using psql 

 

### Configure role-based access control for learner, etc 

https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-create-users  

https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-configure-sign-in-azure-ad-authentication  

Highlight scenario with lower privileged user or managed identity to access database for a specific purpose. Create the user in the database, assign roles, etc. 

Login with CLI tool and attempt to run two commands (demonstrate user is not an admin) 

 

===Linux + Postgres=== 

## Verify the application is running and fully functional 

Hit the endpoint on the application that works with data within the database 

Make sample application more interactive than just Hello World 

Add some specific to Azure pieces that leverage Go etc and have it work with some AI-based extensions? 

Pull in arbitrary data? 

AI summarization? 

Talk about costs and importance of cleanup (don’t leave anything running)  

“This is a demo environment, tear it down using this process” 

“This is what it costs to leave the VM and database running” - how to pause database (if you pause both of them, here’s what you’ll be charged for the paused resources) 
