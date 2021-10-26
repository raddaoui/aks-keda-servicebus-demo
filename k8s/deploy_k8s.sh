kubectl create ns sbprocessor
kubectl create secret generic -n sbprocessor sb-conn-string --from-literal=CONNECTION_STR="Endpoint=sb://myaks-sb-27.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=blablabla"
kubectl apply -n sbprocessor -f sb_processor_deployment.yaml
kubectl apply -n sbprocessor -f sb_processor_scaledobje.yaml