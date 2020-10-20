SP_NAME=skgc-vrd-prod-aks-sp

az ad sp create-for-rbac --skip-assignment --name $SP_NAME

az ad sp list | jq '.[] | select(.displayName | test("skgc-vrd-prod-aks-sp"))'

SP_APP_ID=73745db8-21c4-47c0-8ea9-6b95f1ff612c
UDR_ID=/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourceGroups/skgc-vrd-prod-koce-network-rg/providers/Microsoft.Network/routeTables/skgc-vrd-prod-koce-001-udr
SUBNET_ID=/subscriptions/2dbedacf-40ac-4b61-8bdc-a3025e767aee/resourceGroups/skgc-vrd-prod-koce-network-rg/providers/Microsoft.Network/virtualNetworks/vrd-001-vnet/subnets/skgc-vrd-prod-koce-app-001-subnet
az role assignment create --assignee $SP_APP_ID --scope $UDR_ID --role "Network contributor"
az role assignment create --assignee $SP_APP_ID --scope $SUBNET_ID --role "Network contributor"