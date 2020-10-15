SUBSCRIPTION=2dbedacf-40ac-4b61-8bdc-a3025e767aee
RESOURCE_GROUP=skgc-test
SUBNET_ID=/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourceGroups/skgc-vrd-prod-koce-network-rg/providers/Microsoft.Network/virtualNetworks/vrd-001-vnet/subnets/skgc-vrd-dev-koce-app-002-subnet
CLUSTER_NAME=skgc-vrd-dev-aks-test

az aks create \
    --subscription $SUBSCRIPTION \
    --resource-group $RESOURCE_GROUP \
    --name $CLUSTER_NAME \
    --load-balancer-sku standard \
    --enable-private-cluster \
    --network-plugin kubenet \
    --network-policy calico \
    --vnet-subnet-id $SUBNET_ID \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.2.0.10 \
    --service-cidr 10.2.0.0/24 \
    --pod-cidr 172.110.0.0/16 \
    --node-vm-size Standard_D2s_v3 \
    --nodepool-name vrddevpool \
    --generate-ssh-keys
    --ssh-key-value /home/azureuser/.ssh/vrd.pub



# attach registry
ARC_NAME=skgcvirtualrnd
az aks update --name $CLUSTER_NAME \
    --subscription $SUBSCRIPTION \
    --resource-group $RESOURCE_GROUP \
    --attach-acr $ARC_NAME
