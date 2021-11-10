kubectl create ns sbprocessor
kubectl create secret generic -n sbprocessor sb-conn-string --from-literal=CONNECTION_STR="Endpoint=sb://myaks-sb-27.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=kYY8m4mULTEAO4hzEeFMinx5zpXPPM+g+U1V/0Ck2fA="
kubectl apply -n sbprocessor -f sb_processor_deployment.yaml
kubectl apply -n sbprocessor -f sb_processor_scaledobje.yaml