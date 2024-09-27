# The TT Database Schema

This is the main repo for the TT database schema. There are two main efforts for now: setting up Azure SQL Database for PostgreSQL and Docker.

## Azure PostgreSQL (non-Docker)

You can play around with this by cloning the repo, setting execution permissions, and then installing. Please be sure that you're authenticated to Azure and have a default subscription set.

```sh
git clone https://github.com/Azure-Samples/tailwind-traders
cd tailwind-traders/postgres
chmod +x destroy.sh #mark as executable
```

### Deploying to SQL Database for PostgreSQL (hosted Postgres)

The schema and data are in `tailwind.sql`, so what we need to do is to spin up a PostgreSQL instance and then `psql` the data into it. Everything is handled for you - but if you like have a look in the `deploy.sh` script to be sure you're comfortable with it. I made quite a few opinionated selections, which are...

#### Better Security by Default

Users shouldn't be setting their system administraton accounts - that should be done for them in the same way many VM providers lock down `root` on Unix. To that end, I'm creating a random admin user with a GUID as a password.

#### No 'Oops forgot to drop...'

I'm also defaulting the SKU to `B_Gen4_1`, which is the cheapest. Easy to spin up a demo and get charged a lot! There's a list of SKUs in the script so they can be changed as needed.

#### Connecting With a URL

I'm connecting to `psql` using the format `postgres://...` which allows you set send in the password directly. This makes it super convenient for rolling together a demo.

### The Deployment Command

To send everything up, simply run:

```sh
./deploy.sh
```

You'll be asked for your Resource Group and then off you go. Nothing else should be needed.

### Destroying Things

When you're done, simply run

```sh
az group delete --name=[your resource group]
```

You'll be asked to confirm by entering the Resource Group.

## Use With Docker

Sometimes, for demo purposes, you might want to do something a bit different. Something that launches a bit faster and cleaner - so there's a Docker version of Tailwind you can use for this. It has two parts:

- The PostgreSQL Database that is **not persistent**. That means that when the container dies, so does all of your work. This design choice was made specifically for demo purposes. If you want to make it persistent, just add a volume for `/var/lib/postgresql/data`.

- The PGWeb admin app. It's very basic, but allows you to browse and query the database. There seems to be an editing capability (double-clicking a cell) but I haven't figured out how to make it work.

You can, of course, use `psql` to connect and query if you want.

### Directly, Using PSQL

This is the simplest option. Clone the repo and make sure you have Docker running locally. Then, `cd` into the `/postgres` directory. Have a look around, and if you feel like adding some things to the Dockerfile go for it.

Make sure Docker is running, then use `docker-compose up`. You'll see the build happen - _hopefully you've built and cached the image prior to being on stage_ because... conference wifi and all.

Once built, you can access the database using `psql`:

```
psql "postgresql://tt_user:tt_password@localhost:32221/tt"
```

### Using PGWeb

If you're not a CLI person, you can access the database by opening a browser and navigating to `http://localhost:8080` and you'll see the login screen.

### Cleaning Up

When you're done just CTRL-C out and then `docker-compose down` to clean everything up. **Remember** that you will lose all data unless you mapped a volume.
