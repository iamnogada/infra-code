# azure infra struncture provisioning

> coverage : aks, mariadb, vm, application-gateway \
> using terraform and azure cli

ref: https://www.terraform.io/docs/providers/azurerm/index.html

## preparation: install
1. [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. [helm](https://helm.sh/docs/intro/install/)
4. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
5. util : [jq](https://stedolan.github.io/jq/manual/), yq

### setup vm
- [goto shell](doc/setupvm.md)
- [add user](doc/adduser.md)


## guide for terraform
[doc](doc/overview.md)

## provisioning

### pre-requisite
1. az login
2. create service-principal and keep appId and password
   ``` sh
   SVC_PRINCIPAL_NAME=skgc-vrd-for-terraform
   SUBSCRIPTION_NAME="skgc-vrd"
   SUBSCRIPTION_ID=$(az account list | jq --arg name $SUBSCRIPTION_NAME '.[] | select(.name == $name) | .id' -r)
   az account set  --subscription=$SUBSCRIPTION_ID 
   az ad sp create-for-rbac --name $SVC_PRINCIPAL_NAME --role="Contributor" --scopes=/subscriptions/$SUBSCRIPTION_ID
   ``` 
   ``` json
   {
        "appId": "00000000-0000-0000-0000-000000000000",
        "displayName": "azure-cli-2017-06-05-10-41-15",
        "name": "http://azure-cli-2017-06-05-10-41-15",
        "password": "0000-0000-0000-0000-000000000000",
        "tenant": "00000000-0000-0000-0000-000000000000"
   }
   ```
3. create storage account for terraform remote state
   ``` sh
   #!/bin/bash

   RESOURCE_GROUP_NAME=skgc-vrd-prod-koce-tstate-rg
   STORAGE_ACCOUNT_NAME=skgcvrdtstate
   CONTAINER_NAME=tstate

   # Create resource group
   az group create --name $RESOURCE_GROUP_NAME --location koreacentral

   # Create storage account
   az storage account create --resource-group $RESOURCE_GROUP_NAME --name $STORAGE_ACCOUNT_NAME --sku Standard_LRS --encryption-services blob

   # Get storage account key
   ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP_NAME --account-name $STORAGE_ACCOUNT_NAME | jq '.[0]|.value' -r)

   # Create blob container
   az storage container create --name $CONTAINER_NAME --account-name $STORAGE_ACCOUNT_NAME --account-key $ACCOUNT_KEY

   echo "storage_account_name: $STORAGE_ACCOUNT_NAME"
   echo "container_name: $CONTAINER_NAME"
   echo "access_key: $ACCOUNT_KEY"
   ```
4. set default env for azurerm : save service principal json as 'sp.json'
   
   ARM_CLIENT_ID=appId  
   ARM_CLIENT_SECRET=password  
   ARM_TENANT_ID=tenant  
   SP_FILE=[../sp.json]

   ``` sh
   SUBSCRIPTION_NAME="skgc-vrd"
   SP_FILE=./sp.json
   export SUBSCRIPTION_ID=$(az account list | jq --arg name $SUBSCRIPTION_NAME '.[] | select(.name == $name) | .id' -r)
   export ARM_CLIENT_ID=$(jq '.appId' $SP_FILE -r)
   export ARM_CLIENT_SECRET=$(jq '.password' $SP_FILE -r)
   export ARM_TENANT_ID=$(jq '.tenant' $SP_FILE -r)
   export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
   export TF_VAR_client_id=$ARM_CLIENT_ID
   export TF_VAR_client_secret=$ARM_CLIENT_SECRET
   ```


### aks setting
1. get service-principal of aks
2. assign contribute role on aks

```sh
AKS_RESOURCEID=/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourcegroups/skgc-vrd-prod-koce-aks-rg/providers/Microsoft.ContainerService/managedClusters/skgc-vrd-prod-koce-aks
PRINCIPAL_ID=$(az role assignment list --scope $AKS_RESOURCEID |jq '.[0]|.principalId' -r)
AKS_SUBNET_ID=/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourceGroups/skgc-vrd-prod-koce-network-rg/providers/Microsoft.Network/virtualNetworks/vrd-001-vnet/subnets/skgc-vrd-prod-koce-aks-001-subnet

az role assignment create --assignee $PRINCIPAL_ID --scope $AKS_SUBNET_ID --role Contributor
```
