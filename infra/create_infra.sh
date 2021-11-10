
# define variables
RG="aks-keda-servicebus-demo-rg"
CLUSTER_NAME="myaks"
VNET_NAME="myaks-vnet"
CLUSTER_SUBNET_NAME="myaks-subnet"
ACI_SUBNET_NAME="myaci-subnet"
LOCATION="eastus"
SB_NAMESPACE="myaks-sb-27"
SB_TOPIC="mytopic"
SB_SUBSCRIPTION="s1"
# set this to the name of your Azure Container Registry.  It must be globally unique
ACR_NAME="myaksAlaContainerRegistry"

# create resource group
az group create --name $RG --location $LOCATION

az network vnet create \
 --resource-group $RG \
 --name $VNET_NAME \
 --address-prefixes 10.0.0.0/8 \
 --subnet-name $CLUSTER_SUBNET_NAME \
 --subnet-prefix 10.0.0.0/16

az network vnet subnet create \
 --name $ACI_SUBNET_NAME \
 --resource-group $RG \
 --vnet-name $VNET_NAME \
 --address-prefix 10.1.0.0/24

SUBNET_CLUSTER_ID=$(az network vnet subnet show --resource-group $RG --vnet-name $VNET_NAME --name $CLUSTER_SUBNET_NAME --query id -o tsv)

SUBNET_ACI_ID=$(az network vnet subnet show --resource-group $RG --vnet-name $VNET_NAME --name $ACI_SUBNET_NAME --query id -o tsv)

# Run the following line to create an Azure Container Registry if you do not already have one
az acr create -n $ACR_NAME -g $RG --sku basic

# create AKS cluster
az aks create \
 --resource-group $RG \
 --name $CLUSTER_NAME \
 --enable-managed-identity \
 --network-plugin azure \
 --vnet-subnet-id $SUBNET_CLUSTER_ID \
 --docker-bridge-address 172.17.0.1/16 \
 --service-cidr 10.2.0.0/24 \
 --dns-service-ip 10.2.0.10 \
 --enable-managed-identity \
 --generate-ssh-keys \
--enable-aad \
--enable-azure-rbac \
--disable-local-accounts \
--attach-acr $ACR_NAME \
--yes

# assign youself AKS Azure RBAC cluster admin role
myuserid=$(az ad signed-in-user show --query "userPrincipalName" -o tsv)
# Get AKS cluster Resource ID
aks_id=$(az aks show -g $RG -n $CLUSTER_NAME --query id -o tsv)
# replace AAD-ENTITY-ID with your account email
az role assignment create --role "Azure Kubernetes Service RBAC Cluster Admin" --assignee $myuserid --scope $aks_id


# create service bus namespace, topic/sub
az servicebus namespace create --resource-group $RG --name $SB_NAMESPACE --location $LOCATION
az servicebus topic create --resource-group $RG   --namespace-name $SB_NAMESPACE --name $SB_TOPIC
az servicebus topic subscription create --resource-group $RG --namespace-name $SB_NAMESPACE --topic-name $SB_TOPIC --name $SB_SUBSCRIPTION

# get connection string for service bus namespace
az servicebus namespace authorization-rule keys list --resource-group $RG --namespace-name $SB_NAMESPACE --name RootManageSharedAccessKey --query primaryConnectionString --output tsv