resource_group_name="myaks-rg"
resource_group_location="eastus"
az group create --name $resource_group_name --location $resource_group_location #use this command when you need to create a new resource group for your deployment
az deployment group create --resource-group $resource_group_name --template-file aksdeploy.json --parameters @aksdeploy.parameters.json
