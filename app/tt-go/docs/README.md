# Deploy 

## 1. Deploy Azure Database for PostgreSQL Flexible Server using Bicep
- requires user assigned managed identity
- configure managed identity for entra id admin

## 2. Configure Azure CLI user as Entra ID admin

## 3. Configure firewall rule to allow local IP
- automatically retrieve local IPv4 address

## 4. Get Entra ID password to connect to server

## 5. Connect to server using psql

## 6. (Optional) Deploy a VM and connect via Managed Identity using Go and/or Python

## Resources

- <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-bicep?tabs=CLI>
- <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-connect-with-managed-identity>
- <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-configure-sign-in-azure-ad-authentication>
- <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-manage-firewall-cli>
- <https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-connect-with-managed-identity#connect-using-managed-identity-in-c>
