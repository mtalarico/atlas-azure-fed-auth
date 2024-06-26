# atlas-azure-fed-auth
Terraform + Driver code (currently Python and Java) to establish infrastructure on MongoDB Atlas and Microsoft Azure for Workforce and Workload Federated Database Authentication
# WARNING: Federated Identity GA broke the automated Atlas Database user atlas, all Atlas actions except the project and cluster creation must be done manually until the Terraform Provider is updated

## Prerequisites
- Azure CLI
- Terraform
- Git
- Kubectl
- Org Owner for MongoDB Atlas Organization
- Access to request resources on an active Azure Subscription

## TODO
- [ ] Automatically register Kubernetes provider
- [ ] Private Endpoint setup for AKS and ASE
- [x] ASE: Inject environment variables
- [x] Automatically deploy pod
- [x] AKS: Inject environment variables
- [x] AKS: Custom image with oidc.py

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
5. Init and apply infrastructure
```
terraform init
// (optional, depends on your workflow) terraform plan
terraform apply
```
6. Wait to finish provisioning…
    - Note: ASE took on average 3.5 hours to provision, you can watch Godfather II during this time
7. Manually update federation settings for MongoDB Atlas to match app registration


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