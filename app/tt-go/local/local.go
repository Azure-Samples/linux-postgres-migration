//go:build mage
// +build mage

package main

import (
	"encoding/json"
	"fmt"

	"github.com/magefile/mage/mg"
	"github.com/magefile/mage/sh"
	"github.com/miekg/dns"
)

type Local mg.Namespace

// Test <name> prints a test message
func (Local) Test(name string) error {
	fmt.Printf("Testing deployment to: %s\n", name)
	return nil
}

// ipFromDNS gets the IPv4 address from the whoami.cloudflare. DNS record
func ipFromDNS() (string, error) {
	address := "1.0.0.1:53"
	record := "whoami.cloudflare."

	m := dns.Msg{}
	m.SetQuestion(record, dns.TypeTXT)
	m.Question[0].Qclass = dns.ClassCHAOS

	c := dns.Client{}
	r, _, err := c.Exchange(&m, address)
	if err != nil {
		return "", err
	}
	for _, x := range r.Answer {
		if result, ok := x.(*dns.TXT); ok {
			return result.Txt[0], nil
		}
	}
	return "", fmt.Errorf("no answer found")
}

// IP prints the public IPv4 address of the current machine
func (Local) IP() error {
	ip, err := ipFromDNS()
	if err != nil {
		return err
	}
	fmt.Printf(ip)
	return nil
}

// AccessToken is the struct for az account get-access-token
type AccessToken struct {
	AccessToken  string `json:"accessToken"`
	ExpiresOn    string `json:"expiresOn"`
	Expires_on   int    `json:"expires_on"`
	Subscription string `json:"subscription"`
	Tenant       string `json:"tenant"`
	TokenType    string `json:"tokenType"`
}

// getAccessToken gets the access token from az account get-access-token
func getAccessToken() (*AccessToken, error) {
	cmd1 := []string{
		"az",
		"account",
		"get-access-token",
		"--resource-type",
		"oss-rdbms",
	}
	out1, err := sh.Output(cmd1[0], cmd1[1:]...)
	if err != nil {
		return nil, err
	}

	struct1 := AccessToken{}
	if err := json.Unmarshal([]byte(out1), &struct1); err != nil {
		return nil, err
	}
	return &struct1, nil
}

// AccessToken prints the Microsoft Entra ID access token
func (Local) AccessToken() error {
	token1, err := getAccessToken()
	if err != nil {
		return err
	}
	fmt.Printf(token1.AccessToken)
	return nil
}

// UpdateAdmin <resourceGroup> updates the admin user of
// the Postgres server to the currently signed in user
// using postgres-admin.bicep
func (Local) UpdateAdmin(resourceGroup string) error {
	cmd1 := []string{
		"az",
		"postgres",
		"flexible-server",
		"list",
		"--resource-group",
		resourceGroup,
		"--query",
		"[0].name",
		"--out",
		"tsv",
	}
	serverName, err := sh.Output(cmd1[0], cmd1[1:]...)
	if err != nil {
		return err
	}
	if serverName == "" {
		return fmt.Errorf("no server found")
	}

	user := struct {
		ID                string `json:"id"`
		DisplayName       string `json:"displayName"`
		UserPrincipalName string `json:"userPrincipalName"`
	}{}
	cmd1 = []string{
		"az",
		"ad",
		"signed-in-user",
		"show",
	}
	out1, err := sh.Output(cmd1[0], cmd1[1:]...)
	if err != nil {
		return err
	}
	if err := json.Unmarshal([]byte(out1), &user); err != nil {
		return err
	}

	cmd1 = []string{
		"az",
		"deployment",
		"group",
		"create",
		"--resource-group",
		resourceGroup,
		"--template-file",
		"local/bicep/postgres-admin.bicep",
		"--parameters",
		"postgresName=" + serverName,
		"principalId=" + user.ID,
		"principalName=" + user.UserPrincipalName,
		"principalType=User",
	}
	return sh.RunV(cmd1[0], cmd1[1:]...)
}

// UpdateFirewall <resourceGroup> updates the firewall rule of
// the Postgres server to the current machine's IP address
func (Local) UpdateFirewall(resourceGroup string) error {
	cmd1 := []string{
		"az",
		"postgres",
		"flexible-server",
		"list",
		"--resource-group",
		resourceGroup,
		"--query",
		"[0].name",
		"--out",
		"tsv",
	}
	serverName, err := sh.Output(cmd1[0], cmd1[1:]...)
	if err != nil {
		return err
	}
	if serverName == "" {
		return fmt.Errorf("no server found")
	}

	ipAddress, err := ipFromDNS()
	if err != nil {
		return err
	}

	cmd1 = []string{
		"az",
		"postgres",
		"flexible-server",
		"firewall-rule",
		"update",
		"--name",
		serverName,
		"--rule-name",
		"DefaultAllowRule",
		"--resource-group",
		resourceGroup,
		"--start-ip-address",
		ipAddress,
		"--end-ip-address",
		ipAddress,
	}
	return sh.RunV(cmd1[0], cmd1[1:]...)
}

// Psql <resourceGroup> opens a psql shell to the Postgres
// server using the current logged in user and the access
// token from az account get-access-token
func (Local) Psql(resourceGroup string) error {
	cmd1 := []string{
		"az",
		"postgres",
		"flexible-server",
		"list",
		"--resource-group",
		resourceGroup,
		"--query",
		"[0].name",
		"--out",
		"tsv",
	}
	serverName, err := sh.Output(cmd1[0], cmd1[1:]...)
	if err != nil {
		return err
	}

	// psql "host=mydb.postgres... user=user@tenant.onmicrosoft.com dbname=postgres sslmode=require"

	cmd1 = []string{
		"az",
		"account",
		"show",
		"--query",
		"user.name",
		"--out",
		"tsv",
	}

	pgHost := fmt.Sprintf("%s.postgres.database.azure.com", serverName)

	pgUser, err := sh.Output(cmd1[0], cmd1[1:]...)
	if err != nil {
		return err
	}

	pgPass, err := getAccessToken()
	if err != nil {
		return err
	}

	pgDatabase := "postgres"
	pgSSLMode := "require"

	sh.RunWithV(map[string]string{
		"PGUSER":     pgUser,
		"PGHOST":     pgHost,
		"PGPASSWORD": pgPass.AccessToken,
		"PGDATABASE": pgDatabase,
		"PGSSLMODE":  pgSSLMode,
	}, "psql")

	return nil
}
