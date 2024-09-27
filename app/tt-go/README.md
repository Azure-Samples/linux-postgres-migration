# tt-go

tt-go is an application workload, written in Go, that targets Linux and Postgres. It demonstrates how to:

- Configure the Firewall and Administrator for the Postgres server and access it locally using psql and Entra ID for your own user
- Access the Postgres server locally or from a VM using Entra ID and a Managed Identity (User Assigned) using Go and the
`azidentity` package.

This project uses [Mage](https://magefile.org/), a make-like build tool written in Go. Mage enables us to write `targets` as simple Go functions. If you have mage installed, you can run `mage` instead of `go run main.go`. However, we include mage as a library via the [zero install](https://magefile.org/zeroinstall/) so you can run `go run main.go` without installing mage.

These workflows are designed to be both developer and automation-friendly, including GitHub Actions and Executable Docs.

## Requirements
- [Go (1.21+)](https://go.dev/doc/install)
- [psql](https://www.postgresql.org/docs/current/app-psql.html) CLI (e.g. `apt-get install postgresql-client` or `brew install libpq`)
- (Optional) [Mage](https://magefile.org/)

## 1. Local

Change to the `local/` directory.

```
cd local
```

Output of `go run main.go`:

```
$ go run main.go
Targets:
  local:accessToken       prints the Microsoft Entra ID access token
  local:ip                prints the public IPv4 address of the current machine
  local:psql              <resourceGroup> opens a psql shell to the Postgres server using the current logged in user and the access token from az account get-access-token
  local:test              <name> prints a test message
  local:updateAdmin       <resourceGroup> updates the admin user of the Postgres server to the currently signed in user using postgres-admin.bicep
  local:updateFirewall    <resourceGroup> updates the firewall rule of the Postgres server to the current machine's IP address
```

## 1.1 Usage

For the Postgres server in `240800-linux-postgres`, update the firewall to the current machine's IP address, update the admin user to the current user, and connect to the server using `psql`.

```
go run main.go \
    local:updatefirewall 240800-linux-postgres \
    local:updateadmin 240800-linux-postgres \
    local:psql 240800-linux-postgres
```

## 2. Application

Change to the `app/` directory.

```
cd local
```

Output of `go run main.go`:

```
$ go run main.go
Targets:
  app:sql      sets up the environment for connecting to a PostgreSQL database
  app:token    gets a token using `azidentity.NewDefaultAzureCredential`
```
