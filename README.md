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

# az aks get credentials
SUBSCRIPTION_ID=2dbedacf-40ac-4b61-8bdc-a3025e767aee
RESOURCE_GROUP=skgc-vrd-prod-koce-app-rg

az aks get-credentials -n vrd-prod-aks -g $RESOURCE_GROUP --subscription $SUBSCRIPTION_ID --admin


# create service-account

ADMIN=admin
kubectl create serviceaccount $ADMIN -n kube-system

cat << EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: $ADMIN
  namespace: kube-system
EOF

TOKEN=$(kubectl -n kube-system get secret $(kubectl -n kube-system get secret | grep $ADMIN-token | awk '{print $1; exit}') -o jsonpath='{.data.token}' | base64 -d)
kubectl config set-credentials $ADMIN --token=$TOKEN



# docker secret in k8s
kubectl create secret docker-registry skgcvrd \
    --namespace sam \
    --docker-server=skgcvrd.azurecr.io \
    --docker-username=skgcvrd \
    --docker-password=d8kWcmM/S0lr7k7K4Tdf0YcDtboHJRFl


# enable agic
az feature register --name AKS-IngressApplicationGatewayAddon --namespace microsoft.containerservice

appgwId=$(az network application-gateway show -n skgc-vrd-prod-appgw -g skgc-vrd-prod-koce-dmz-rg -o tsv --query "id")

az aks enable-addons -n vrd-prod-aks -g skgc-vrd-prod-koce-app-rg -a ingress-appgw --appgw-id $appgwId


# import container image
- docker.io/jettech/kube-webhook-certgen:v1.3.0  : skgcvrd.azurecr.io/ski/kube-webhook-certgen:v1.3.0
  - sha256:ff01fba91131ed260df3f3793009efbf9686f5a5ce78a85f81c386a4403f7689
  - new : sha256:e56ed7cc581c0fa70a02a8e568e5cd5fe8c971cf8de82c22fd101366840595e7
- k8s.gcr.io/defaultbackend-amd64:1.5            : skgcvrd.azurecr.io/ski/defaultbackend-amd64:1.5
  - sha256:4dc5e07c8ca4e23bddb3153737d7b8c556e5fb2f29c4558b7cd6e6df99c512c7
  - new: sha256:4dc5e07c8ca4e23bddb3153737d7b8c556e5fb2f29c4558b7cd6e6df99c512c7
- k8s.gcr.io/ingress-nginx/controller:v0.40.2     : skgcvrd.azurecr.io/ski/controller:v0.40.2
  - sha256:46ba23c3fbaafd9e5bd01ea85b2f921d9f2217be082580edc22e6c704a83f02f
  - new: sha256:0100c173327bbb124c76ea1511dade4cec718234c23f8e7a41f27ad03f361431

kubectl create secret docker-registry skgcvrd \
    --namespace ingress-basic \
    --docker-server=skgcvrd.azurecr.io \
    --docker-username=skgcvrd \
    --docker-password=d8kWcmM/S0lr7k7K4Tdf0YcDtboHJRFl

helm upgrade ingress ./ingress-nginx \
    --namespace ingress-basic \
    -f internal-ingress.yaml \
    --set controller.replicaCount=2 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --install