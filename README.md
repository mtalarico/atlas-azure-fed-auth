# atlas-azure-fed-auth
Terraform + Driver code (currently Python, Java, and Go with directions for testing mongosync) to establish infrastructure on MongoDB Atlas and Microsoft Azure for Workforce and Workload Federated Database Authentication

## Note
Federated Authentication for the Data Plane is now GA! This repository has been updated to demonstrate the GA terraform behavior. The only remaining manual work that must be done
is linking and unlinking the Identity Providers in the Atlas Federation Authentication Settings App before users can log in.

This can technically be done automatically, but for simplicity of this example module, it is left as a manual step for the user both upon `terraform apply` and `terraform destroy`.
Please see the Setup/Teardown sections below for instructions or [atlas_federation.tf:35](https://github.com/mtalarico/atlas-azure-fed-auth/blob/29c00b45d9563221236974eaee7f28119c6cdc11/terraform/atlas_federation.tf#L35) for more technical detail.


## Prerequisites
- Azure CLI
- Terraform
- Git
- Kubectl
- Org Owner for MongoDB Atlas Organization
- Access to request resources on an active Azure Subscription

## Setup
1. Clone repository
```
git clone https://github.com/mtalarico/atlas-azure-fed-auth
```
2. Export variables
```
export AZURE_PREFIX="oidc-test"
export ARM_SUBSCRIPTION_ID="<your azure subscription id>"
```
3. Login to Azure CLI
```
az login
```
4. Create Terraform variables file / input variables
```
cp terraform.tfvars.template.json terraform.tfvars.json
```
5. Replace values in `terraform.tfvars.json`.
    - **If using Vault** set `vault.enabled = true`, `vault.uri`, and `api_key.vault_path`
    - **If not using Vault** set `vault.enabled = false`, `api_key.public_key`, and `api_key.private_key`
6. Init and apply infrastructure
```
terraform init
// (optional, depends on your workflow) terraform plan
terraform apply
```
7. Wait to finish provisioning…
    - Note: ASE took on average 3.5 hours to provision, you can watch Godfather II during this time
8. **Warning:** this will probably error out on the Kubernetes/AKS portion. When it does, run the following and then return `terraform apply` to finish up the K8s portion
```
az aks get-credentials --resource-group ${AZURE_PREFIX}-example-aks-rg --name ${AZURE_PREFIX}-example-aks-cluster
```
9. Run terraform apply again because some parts cannot finish without the az credentials.
```
terraform apply
```
10. Navigate to `Atlas Org Settings > Open Federation Management App > Linked Organizations`
11. Either link your desired org or select an already linked org's `Configure Access`
12. `Connect Identity Providers`, selecting the Workforce and Workload IdPs
13. Make sure that the kube pod can communicate with Atlas by setting the IP for the pod in the
    Atlas allowed IPs for the project. It is easiest just to add 0.0.0.0 to the allow list.

## Teardown
1. Navigate to `Atlas Org Settings > Open Federation Management App > Linked Organizations`
2. Either link your desired org or select an already linked org's `Configure Access`
3. `Manage > Disconnect Identity Provider` for each IdP that is going to be deleted
4. Destory infrastructure
```
terraform destroy
```

## Workforce
1. Login via `mongosh`
```
mongosh "${MONGODB_URI}/?authSource=%24external&authMechanism=MONGODB-OIDC&appName=workforceTest"
```


## Workload - ASE - Python
1. Open connection to ASE
```
az webapp create-remote-connection  --resource-group ${AZURE_PREFIX}-example-ase-rg --name ${AZURE_PREFIX}-example-ase-python-app
```
2. Connect to ASE using port from step 1's output
```
ssh root@127.0.0.1 -p ${OUTPUT_PORT}
```
3. Copy over oidc.py and requirements.txt
4. Install required dependencies
```
pip3 install -r requirements.txt
```
5. Run oidc.py
```
python3 oidc.py
```

## Workload - ASE - Java
1. (Optional) package JAR under `./java`
```
mvn clean package
```
2. Open connection to ASE
```
az webapp create-remote-connection  --resource-group ${AZURE_PREFIX}-example-ase-rg --name ${AZURE_PREFIX}-example-ase-python-app
```
3. Connect to ASE using port from step 1's output
```
ssh root@127.0.0.1 -p ${OUTPUT_PORT}
```
4. Copy over `java/target/oidc-0.0.1.jar`
5. Run `oidc-0.0.1.jar`
```
java -jar oidc-0.0.1.jar
```


## Workload - AKS - Python
1. Open connection to AKS
```
kubectl exec -it ${AZURE_PREFIX}-example-aks-app -- /bin/bash
```
2. Run oidc.py
```
python3 oidc.py
```

## Workload - AKS - Java
1. Open connection to AKS
```
kubectl exec -it ${AZURE_PREFIX}-example-aks-app -- /bin/bash
```
2. Build the jar
```
./mvnw clean package
```
3. Run
```
./mvnw clean package
```
4. Run `oidc-0.0.1.jar`
```
java -jar oidc-0.0.1.jar
```

## Workload - AKS - Go
1. Open connection to AKS
```
kubectl exec -it ${AZURE_PREFIX}-example-aks-app -- /bin/bash
```
2. Run ./oidc
```
./oidc

```
or
```
go run oidc.go
```

### Testing mongosync
I did not create a separate Docker image for testing mongosync. In general, the oidc go test above shows that mongosync will work,
but for extra verification, we first need to copy our ssh private key to the kube:
1. Copy key (on macos it looks like the following, change the local path as necesary for other OS)
```
kubectl cp /Users/<user name>/.ssh/id_rsa  ${AZURE_PREFIX}-example-aks-app:/root/.ssh/id_rsa
```

2. Log into the pod as above:
```
kubectl exec -it ${AZURE_PREFIX}-example-aks-app -- /bin/bash
```

3. Clone the repo:
```
git clone git@github.com:10gen/mongosync
```

4. In order to build mongosync, we need to install gsappi (the go driver requires it)
```
apt-get install libkrb5-dev
```

5. Now build mongosync
```
cd mongosync && go run mage.go build
```

6. We just need to test the connections, so we will use the same source and destination clusters just to confirm they connect successfully
```
export c="${MONGODB_URI}/?authMechanism=MONGODB-OIDC&appName=oidcTest&authMechanismProperties=ENVIRONMENT:azure"
./dist/mongosync --cluster0 $c --cluster1 $c
```
The user in the terraform is not set up to run all commands, so expect the following warnings and other failures with regars to `replSetGetConfig`, but other commands will issue successully:
```
{"time":"2024-09-24T18:34:12.706204Z","level":"debug","serverID":"cad79626","mongosyncID":"coordinator","clusterType":"dst","isDriverLog":true,"driverCommand":"replSetGetConfig","connectionID":"example-cluster-shard-00-02.f23iu.mongodb.net:27017[-7]","duration":"775.198µs","requestID":44,"failure":"(Unauthorized) not authorized on admin to execute command { replSetGetConfig: 1, lsid: { id: UUID(\"287a880f-99a7-406a-8eb7-c85ee7d89c4c\") }, $clusterTime: { clusterTime: Timestamp(1727202852, 2), signature: { hash: BinData(0, B1EAEA02625EA39609F04B2785A6D078D48FA235), keyId: 7418240528371679237 } }, maxTimeMS: 300000, $db: \"admin\" }","serverConnectionID":1726,"message":"Command failed."}
{"time":"2024-09-24T18:34:12.706493Z","level":"debug","serverID":"cad79626","mongosyncID":"coordinator","operationID":"9e52a6aa","clientType":"destination","database":"admin","operationDescription":"Retrieving replicaSetId from admin database.","attemptNumber":0,"totalTimeSpent":"880ns","retryAttemptDurationSoFarSecs":0,"retryAttemptDurationLimitSecs":600,"handledError":{"msErrorLabels":["serverError"],"clientType":"destination","database":"admin","failedCommand":"RunCommand","failedRunCommand":"[{replSetGetConfig 1}]","message":"failed to execute a command on the MongoDB server: (Unauthorized) not authorized on admin to execute command { replSetGetConfig: 1, lsid: { id: UUID(\"287a880f-99a7-406a-8eb7-c85ee7d89c4c\") }, $clusterTime: { clusterTime: Timestamp(1727202852, 2), signature: { hash: BinData(0, B1EAEA02625EA39609F04B2785A6D078D48FA235), keyId: 7418240528371679237 } }, maxTimeMS: 300000, $db: \"admin\" }"},"message":"Not retrying on error because it is not transient nor is it in our additional codes list."}
{"time":"2024-09-24T18:34:12.706575Z","level":"debug","serverID":"cad79626","mongosyncID":"coordinator","handledError":{"msErrorLabels":["serverError"],"clientType":"destination","database":"admin","operationDescription":"Retrieving replicaSetId from admin database.","failedCommand":"RunCommand","failedRunCommand":"[{replSetGetConfig 1}]","message":"failed to retrieve replicaSetId from admin database: failed to execute a command on the MongoDB server: (Unauthorized) not authorized on admin to execute command { replSetGetConfig: 1, lsid: { id: UUID(\"287a880f-99a7-406a-8eb7-c85ee7d89c4c\") }, $clusterTime: { clusterTime: Timestamp(1727202852, 2), signature: { hash: BinData(0, B1EAEA02625EA39609F04B2785A6D078D48FA235), keyId: 7418240528371679237 } }, maxTimeMS: 300000, $db: \"admin\" }"},"URI":"example-cluster.f23iu.mongodb.net","message":"Could not get clusterID for cluster0; this only impacts telemetry, and does not otherwise affect the migration."}

```
It is possible to log into the cluster on `cloud.mongodb.com` to give necessary permissions to the user to clear up those warnings. If there is any desire to modify the code for mongosync, vim can be installed on the pod easily:
```
apt-get install vim
```

## TODO
- [ ] Automatically register Kubernetes provider
- [ ] Private Endpoint setup for AKS and ASE
- [x] ASE: Inject environment variables
- [x] Automatically deploy pod
- [x] AKS: Inject environment variables
- [x] AKS: Custom image with oidc.py
