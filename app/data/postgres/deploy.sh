#!/bin/bash
#These are the settings for deployment. The only thing you need to be sure you change is
#the resource group, as that will be the name you will use to destroy things later

USER=admin_$RANDOM #set this to whatever you like but it's not something that should be easy
PASS=$(uuidgen) #Again - whatever you like but keep it safe! Better to make it random
LOCATION=westus
SERVERNAME=tailwind$RANDOM #this has to be unique across azure

echo "Guessing your external IP address from ipinfo.io"
IP=$(curl -s ipinfo.io/ip)
echo "Your IP is $IP"


echo "Enter the name of a Resource Group to use. If it doesn't exist, we'll create it."
read RG

az group create -n $RG -l $LOCATION

#The sku-name parameter value follows the convention {pricing tier}_{compute generation}_{vCores} as in the examples below:
# --sku-name B_Gen4_2 maps to Basic, Gen 4, and 2 vCores.
# --sku-name GP_Gen5_32 maps to General Purpose, Gen 5, and 32 vCores.
# --sku-name MO_Gen5_2 maps to Memory Optimized, Gen 5, and 2 vCores.
SKU=B_Gen4_1 #this is the cheapest one


echo "Spinning up PostgreSQL $SERVERNAME in group $RG Admin is $USER"

# Create the PostgreSQL service
az postgres server create --resource-group $RG \
    --name $SERVERNAME  --location $LOCATION --admin-user $USER \
    --admin-password $PASS --sku-name $SKU --version 10.0

# Open up the firewall so we can access
echo "Popping a hole in firewall for IP address $IP (that's you)"
az postgres server firewall-rule create --resource-group $RG \
        --server $SERVERNAME --name AllowMyIP \
        --start-ip-address $IP --end-ip-address $IP

echo "Your connection string is postgres://$USER@$SERVERNAME:$PASS@$SERVERNAME.postgres.database.azure.com/postgres"
echo "Creating the Tailwind database..."
psql "postgres://$USER%40$SERVERNAME:$PASS@$SERVERNAME.postgres.database.azure.com/postgres" -c "CREATE DATABASE tailwind;"

echo "Connecting... and loading up Tailwind..."
psql "postgres://$USER%40$SERVERNAME:$PASS@$SERVERNAME.postgres.database.azure.com/tailwind" -f tailwind.sql
echo "....."
echo "You can now connect to the server by entering this command: "
echo "psql postgres://$USER%40$SERVERNAME:$PASS@$SERVERNAME.postgres.database.azure.com/tailwind"
