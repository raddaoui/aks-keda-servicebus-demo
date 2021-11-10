RESOURCE_GROUP="aks-keda-servicebus-demo-rg"
LOCATION="canadacentral"
LOG_ANALYTICS_WORKSPACE="containerapps-logs"
CONTAINERAPPS_ENVIRONMENT="containerapps-env"
ACR_NAME="acrAlaContainerRegistry"
SB_NAMESPACE="myaks-sb-27"
SB_TOPIC="mytopic"
SB_SUBSCRIPTION="s1"


# Create resource group
az group create --name $RESOURCE_GROUP --location "$LOCATION"

# Create ACR
az acr create -n $ACR_NAME -g $RESOURCE_GROUP --sku basic --admin-enabled
ACR_SERVER=$(az acr show -n $ACR_NAME --query loginServer -o tsv) # assumes ACR Admin Account is enabled
ACR_UNAME=$(az acr credential show -n $ACR_NAME --query="username" -o tsv)
ACR_PASSWD=$(az acr credential show -n $ACR_NAME --query="passwords[0].value" -o tsv)


# create service bus namespace, topic/sub
az servicebus namespace create --resource-group $RESOURCE_GROUP --name $SB_NAMESPACE --location $LOCATION
az servicebus topic create --resource-group $RESOURCE_GROUP   --namespace-name $SB_NAMESPACE --name $SB_TOPIC
az servicebus topic subscription create --resource-group $RESOURCE_GROUP --namespace-name $SB_NAMESPACE --topic-name $SB_TOPIC --name $SB_SUBSCRIPTION
# get connection string for service bus namespace
CONNECTION_STRING=$(az servicebus namespace authorization-rule keys list --resource-group $RESOURCE_GROUP --namespace-name $SB_NAMESPACE --name RootManageSharedAccessKey --query primaryConnectionString --output tsv)


# Create a new Log Analytics workspace with the following command:
az monitor log-analytics workspace create \
  --resource-group $RESOURCE_GROUP \
  --workspace-name $LOG_ANALYTICS_WORKSPACE

# retrieve the Log Analytics Client ID and client secret.
LOG_ANALYTICS_WORKSPACE_CLIENT_ID=`az monitor log-analytics workspace show --query customerId -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv`
LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET=`az monitor log-analytics workspace get-shared-keys --query primarySharedKey -g $RESOURCE_GROUP -n $LOG_ANALYTICS_WORKSPACE --out tsv`

# create Azure Container Apps environment
az containerapp env create \
  --name $CONTAINERAPPS_ENVIRONMENT \
  --resource-group $RESOURCE_GROUP \
  --logs-workspace-id $LOG_ANALYTICS_WORKSPACE_CLIENT_ID \
  --logs-workspace-key $LOG_ANALYTICS_WORKSPACE_CLIENT_SECRET \
  --location "$LOCATION"



####### NOTE: before you create container app, make sure to create image and store in ACR. 
############# check image folder for steps on how to do it.

# Create container app
az containerapp create \
  --name sb-processor-container-app \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image $ACR_SERVER/sbmessageprocessor:v1 \
  --secrets "sb-conn-string=$CONNECTION_STRING" \
  --environment-variables "CONNECTION_STR=secretref:sb-conn-string" \
  --registry-login-server $ACR_SERVER \
  --registry-username $ACR_UNAME \
  --registry-password $ACR_PASSWD \
  --min-replicas 1 \
  --max-replicas 10 


