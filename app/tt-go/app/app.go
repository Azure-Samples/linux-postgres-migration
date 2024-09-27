//go:build mage
// +build mage

package main

import (
	"context"
	"fmt"

	"github.com/Azure/azure-sdk-for-go/sdk/azcore/policy"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/magefile/mage/mg"
)

type App mg.Namespace

// SQL sets up the environment for connecting to a PostgreSQL database
func (App) SQL() error {
	pgDatabase := "postgres"
	pgSSLMode := "require"

	map1 := map[string]string{
		"PGUSER":     "",
		"PGHOST":     "",
		"PGPASSWORD": "",
		"PGDATABASE": pgDatabase,
		"PGSSLMODE":  pgSSLMode,
	}
	_ = map1

	return nil
}

// Token gets a token using `azidentity.NewDefaultAzureCredential`
func (App) Token() error {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		return err
	}

	opts := policy.TokenRequestOptions{
		Scopes: []string{
			"https://ossrdbms-aad.database.windows.net/.default",
		},
	}

	ctx := context.Background()
	token, err := cred.GetToken(ctx, opts)
	if err != nil {
		return err
	}
	fmt.Printf(token.Token)
	return nil
}
