# atlas-azure-fed-auth
Terraform + Python code to establish infrastructure on MongoDB Atlas and Microsoft Azure for Workforce and Workload Federated Database Authentication

## Prerequisites
- [ ] Azure CLI
- [ ] Terraform
- [ ] Git
- [ ] Kubectl
- [ ] Org Owner for MongoDB Atlas Organization
- [ ] Access to request resources on an active Azure Subscription

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
7. Manually update federation settings for MongoDB Atlas to match app registration


## Workforce
1. Login via `mongosh`
```
mongosh "${MONGODB_URI}/?authSource=%24external&authMechanism=MONGODB-OIDC&appName=workforceTest"
```


## Workload - ASE
1. Open connection to ASE 
```
az webapp create-remote-connection  --resource-group ${AZURE_PREFIX}-example-ase-rg --name ${AZURE_PREFIX}-example-ase-python-app
```
2. Connect to ASE using port from step 1’s output
```
ssh root@127.0.0.1 -p ${OUTPUT_PORT}
```
3. Copy over oidc.py and requirements.txt
4. Install required dependencies
```
apt update && apt install git wget -y && pip3 install -r requirements.txt
```
5. Run oidc.py
```
python3 oidc.py
```


## Workload - AKS
1. Open connection to AKS
```
kubectl exec -it ${AZURE_PREFIX}-example-aks-python-app -- /bin/bash
```
2. Run oidc.py
```
python3 oidc.py
```



