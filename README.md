# azure infra struncture provisioning

> coverage : aks, mariadb, vm, application-gateway \
> using terraform and azure cli

ref: https://www.terraform.io/docs/providers/azurerm/index.html

## preparation: install
1. [azure cli](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. [helm](https://helm.sh/docs/intro/install/)
4. [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## provisioning

### pre-requisite
1. get subscription id
   ``` shell
   az account list --output table
   export SUBSCRIPTION_ID = (id)
   ```
2. create service-principal and keep appId and password
   ``` shell
   SVC_PRINCIPAL_NAME=(service pricipal name)
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
3. Set environment  
   ARM_CLIENT_ID=appId  
   ARM_CLIENT_SECRET=password  
   ARM_TENANT_ID=tenant  

   ```shell
   $ export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
   $ export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
   $ export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
   $ export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
   $ export VNET_ID="00000000-0000-0000-0000-000000000000"
   $ export VNET_RG_ID="00000000-0000-0000-0000-000000000000"
### common resource
> vnet, default resource-group is already provisioned
> default resource to provision : subnet, udr

1. cd ./common
2. terraform init
3.  