package com.mongodb.oidc;

import org.bson.Document;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.core.env.Environment;

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

@SpringBootApplication
public class WorkloadApplication {

	private static final Logger logger = LoggerFactory.getLogger(WorkloadApplication.class);

	@Value("${mongodb.uri}")
	private String mongodbUri;

	@Value("${azure.client-id}")
	private String clientId;

	@Value("${azure.app-id}")
	private String appId;

	public static void main(String[] args) {
		SpringApplication.run(WorkloadApplication.class, args);
	}

	@Bean
	public CommandLineRunner commandLineRunner(Environment env) {
		return args -> {
			if (mongodbUri == null || clientId == null || appId == null) {
				logger.info("One or more environment variables are not set.");
				System.exit(1);
			}

			OidcCallback callback = (context) -> {
				DefaultAzureCredential defaultCredential = new DefaultAzureCredentialBuilder()
						.managedIdentityClientId(clientId)
						.build();
				AccessToken token = defaultCredential
						.getTokenSync(new TokenRequestContext().addScopes(String.format("api://%s/.default", appId)));
				return new OidcCallbackResult(token.getToken());
			};

			MongoCredential credential = MongoCredential.createOidcCredential(null).withMechanismProperty(
					"OIDC_CALLBACK",
					callback);

			MongoClientSettings clientBuilder = MongoClientSettings.builder()
					.applyConnectionString(new ConnectionString(mongodbUri))
					.credential(credential)
					.build();
			try (MongoClient client = MongoClients.create(clientBuilder)) {
				// Ping the server
				MongoDatabase adminDb = client.getDatabase("admin");
				Document ping = new Document("ping", 1);
				adminDb.runCommand(ping);

				// Successfully connected message
				logger.info("----------------------------------");
				logger.info("Successfully connected to MongoDB!\n");
				logger.info("----------------------------------");

				// Listing DB names
				logger.info("Listing DB Names");
				for (String dbName : client.listDatabaseNames()) {
					logger.info("DB: " + dbName);
				}
				logger.info("----------------------------------");

				// Accessing a collection
				MongoDatabase testDb = client.getDatabase("test");
				MongoCollection<Document> testCollection = testDb.getCollection("foo");

				// Inserting a document
				Document docToInsert = new Document("foo", "bar test");
				logger.info("Inserting sample record: " + docToInsert);
				testCollection.insertOne(docToInsert);
				logger.info("Inserted ID: " + docToInsert.getObjectId("_id").toHexString());
				logger.info("----------------------------------");

				// Finding inserted document by _id
				logger.info("Finding inserted doc by _id");
				Document findOneResponse = testCollection.find(new Document("_id", docToInsert.getObjectId("_id")))
						.first();
				logger.info("Find response: " + findOneResponse);
			}
		};
	}
}