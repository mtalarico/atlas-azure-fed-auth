# atlas-azure-fed-auth
Terraform + Driver code (currently Python and Java) to establish infrastructure on MongoDB Atlas and Microsoft Azure for Workforce and Workload Federated Database Authentication

## Note
Federated Authentication for the Data Plane is now GA! This repository has been updated to demonstrate the GA terraform behavior. The only remaining manual work that must be done
is linking and unlinking the Identity Providers in the Atlas Federation Authentication Settings App before users can log in.

This can technically be done automatically, but for simplicity of this example module, it is left as a manual step for the user both upon `terraform apply` and `terraform destroy`.
Please see the Setup section below for instructions or [atlas_federation.tf:35](https://github.com/mtalarico/atlas-azure-fed-auth/blob/29c00b45d9563221236974eaee7f28119c6cdc11/terraform/atlas_federation.tf#L35) for more technical detail.


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
export AZURE_PREFIX="mt-wf"
export MONGODB_URI="mongodb+srv://example-cluster.knust.mongodb.net"
```
3. Login to Azure CLI
```
az login && az aks get-credentials --resource-group ${AZURE_PREFIX}-example-aks-rg --name ${AZURE_PREFIX}-example-aks-cluster
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
8. Navigate to `Atlas Org Settings > Open Federation Management App > Linked Organizations`
9. Either link your desired org or select an already linked org's `Configure Access`
10. `Connect Identity Providers`, selecting the Workforce and Workload IdPs


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
kubectl exec -it ${AZURE_PREFIX}-example-aks-python-app -- /bin/bash
```
2. Run oidc.py
```
python3 oidc.py
```

## Workload - AKS - Java
1. Open connection to AKS
```
kubectl exec -it ${AZURE_PREFIX}-example-aks-python-app -- /bin/bash
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

## TODO
- [ ] Automatically register Kubernetes provider
- [ ] Private Endpoint setup for AKS and ASE
- [x] ASE: Inject environment variables
- [x] Automatically deploy pod
- [x] AKS: Inject environment variables
- [x] AKS: Custom image with oidc.py
