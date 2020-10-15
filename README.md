# infra-code



# prepared resource
> vrd-001-vnet, skgc-vrd-prod-koce-network-rg 은 이미 생성되어 있는 자원임.
> 수정 금지








az vm list-sizes -l koreacentral -o table
--> Standard_D2s_v3


az group list --subscription 2dbedacf-40ac-4b61-8bdc-a3025e767aee -o table

az network vnet list --subscription 2dbedacf-40ac-4b61-8bdc-a3025e767aee -o table



az network vnet subnet list --resource-group skgc-vrd-prod-koce-network-rg --vnet-name vrd-001-vnet --subscription 2dbedacf-40ac-4b61-8bdc-a3025e767aee --query [].id

# create pub key from private
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub



sudo useradd [name]





terraform [destroy/apply] -var-file="../default.tfvars"
