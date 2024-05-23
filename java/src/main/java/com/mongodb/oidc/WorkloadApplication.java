package com.mongodb.oidc;

import org.bson.Document;

import com.azure.core.credential.AccessToken;
import com.azure.core.credential.TokenRequestContext;
import com.azure.identity.DefaultAzureCredential;
import com.azure.identity.DefaultAzureCredentialBuilder;
import com.mongodb.ConnectionString;
import com.mongodb.MongoClientSettings;
import com.mongodb.MongoCredential;
import com.mongodb.MongoCredential.OidcCallback;
import com.mongodb.MongoCredential.OidcCallbackResult;
import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

public class WorkloadApplication {
	public static void main(String[] args) {

		String MONGODB_URI = System.getenv("MONGODB_URI");
		String CLIENT_ID = System.getenv("AZURE_IDENTITY_CLIENT_ID");
		String APP_ID = System.getenv("AZURE_APP_CLIENT_ID");

		if (MONGODB_URI == null || CLIENT_ID == null || APP_ID == null) {
			System.out.println("One or more environment variables are not set.");
			System.exit(1);
		}

		OidcCallback callback = (context) -> {
			DefaultAzureCredential defaultCredential = new DefaultAzureCredentialBuilder()
					.managedIdentityClientId(CLIENT_ID)
					.build();
			AccessToken token = defaultCredential
					.getTokenSync(new TokenRequestContext().addScopes(String.format("api://%s/.default", APP_ID)));
			return new OidcCallbackResult(token.getToken());
		};

		MongoCredential credential = MongoCredential.createOidcCredential(null).withMechanismProperty("OIDC_CALLBACK",
				callback);

		MongoClientSettings clientBuilder = MongoClientSettings.builder()
				.applyConnectionString(new ConnectionString(MONGODB_URI))
				.credential(credential)
				.build();
		try (MongoClient client = MongoClients.create(clientBuilder)) {
			// Ping the server
			MongoDatabase adminDb = client.getDatabase("admin");
			Document ping = new Document("ping", 1);
			adminDb.runCommand(ping);

			// Successfully connected message
			System.out.println("----------------------------------");
			System.out.println("Successfully connected to MongoDB!\n");
			System.out.println("----------------------------------");

			// Listing DB names
			System.out.println("Listing DB Names");
			for (String dbName : client.listDatabaseNames()) {
				System.out.println("DB: " + dbName);
			}
			System.out.println("----------------------------------");

			// Accessing a collection
			MongoDatabase testDb = client.getDatabase("test");
			MongoCollection<Document> testCollection = testDb.getCollection("foo");

			// Inserting a document
			Document docToInsert = new Document("foo", "bar test");
			System.out.println("Inserting sample record: " + docToInsert);
			testCollection.insertOne(docToInsert);
			System.out.println("Inserted ID: " + docToInsert.getObjectId("_id").toHexString());
			System.out.println("----------------------------------");

			// Finding inserted document by _id
			System.out.println("Finding inserted doc by _id");
			Document findOneResponse = testCollection.find(new Document("_id", docToInsert.getObjectId("_id"))).first();
			System.out.println("Find response: " + findOneResponse);
		}
	}

}
