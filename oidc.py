import os
from azure.identity import DefaultAzureCredential
from pymongo import MongoClient
from pymongo.auth_oidc import OIDCCallback, OIDCCallbackContext, OIDCCallbackResult

APP_ID = os.environ["AZURE_APP_CLIENT_ID"]
CLIENT_ID = os.environ["AZURE_IDENTITY_CLIENT_ID"]
MONGODB_URI = (
    f"{os.environ['MONGODB_URI']}/?authMechanism=MONGODB-OIDC&appName=oidcTest"
)


class MyCallback(OIDCCallback):
    def fetch(self, context: OIDCCallbackContext) -> OIDCCallbackResult:
        credential = DefaultAzureCredential(managed_identity_client_id=CLIENT_ID)
        token = credential.get_token(f"api://{APP_ID}/.default").token
        return OIDCCallbackResult(access_token=token)


props = dict(OIDC_CALLBACK=MyCallback())
client = MongoClient(MONGODB_URI, authMechanismProperties=props)

try:
    client.admin.command("ping")
    test_collection = client.test.foo
    print("----------------------------------")
    print("Successfully connected to MongoDB!\n")
    print("----------------------------------")
    print("Listing DB Names")
    print(f"DBs: {client.list_database_names()}\n")
    print("----------------------------------")
    doc_to_insert = {"foo": "bar test"}
    print(f"Inserting sample record: {doc_to_insert}")
    insert_response = test_collection.insert_one(doc_to_insert)
    inserted_id = insert_response.inserted_id
    print(f"Inserted ID: {inserted_id}\n")
    print("----------------------------------")
    print("Finding inserted doc by _id")
    find_one_response = test_collection.find_one(inserted_id)
    print(f"Find response: {find_one_response}")
except Exception as e:
    print(e)
