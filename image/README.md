### USE ACR tasls to build container image

        ACR_NAME="myaksAlaContainerRegistry"
        IMAGE_NAME="sbmessageprocessor"
        RG="aks-keda-servicebus-demo-rg"
        #az login # authenticate if you're not
        az acr build --registry $ACR_NAME -g $RG --image $IMAGE_NAME:v1 .
