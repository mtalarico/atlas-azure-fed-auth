package oidc

import (
	"context"
	"fmt"
	"os"

	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/azcore/policy"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var APP_ID string = os.Getenv("AZURE_APP_CLIENT_ID")
var CLIENT_ID string = os.Getenv("AZURE_IDENTITY_CLIENT_ID")
var MONGODB_URI string = fmt.Sprintf(
    "%s/?authMechanism=MONGODB-OIDC&appName=oidcTest",
	os.Getenv("MONGODB_URI"),
)

func AzureManagedIdentityCallback(
	_ context.Context,
	_ *options.OIDCArgs,
) (*options.OIDCCredential, error) {
	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		return nil, nil
	}
	opts := policy.TokenRequestOptions {
		Scopes: []string {
			fmt.Sprintf("api//%s/.default", APP_ID),
		},
	}
	token, err := cred.GetToken(context.Background(), opts)
	if err != nil {
		return nil, nil
	}
	return &options.OIDCCredential{
		AccessToken: token.Token,
		ExpiresAt: &token.ExpiresOn,
	}, nil
}

func Main() {
	opts := options.Client().ApplyURI(MONGODB_URI)
	opts.Auth.OIDCMachineCallback = AzureManagedIdentityCallback
	client, err := mongo.Connect(context.Background(), opts)
	if err != nil {
		panic(err)
	}

    fmt.Println("----------------------------------")
    fmt.Println("Successfully connected to MongoDB!\n")
    fmt.Println("----------------------------------")
    fmt.Println("Listing DB Names")
    fmt.Println("----------------------------------")
	fmt.Println(client.ListDatabaseNames(context.Background(), bson.D{}, nil))
}
