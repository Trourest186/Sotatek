#!/bin/bash

NAMESPACE="kubernetes-dashboard"
SERVICE_ACCOUNT="webadmin"

# Set the path to your recommended.yaml file
YAML_FILE="recommended.yaml"

# Create service account
kubectl apply -f $YAML_FILE

# Create service account at namespace kubernetes-dashboard
if kubectl get sa "$SERVICE_ACCOUNT" -n "$NAMESPACE" &>/dev/null; then
    echo "Service account '$SERVICE_ACCOUNT' already exists in namespace '$NAMESPACE'."
else
    # Create the service account
    kubectl create sa "$SERVICE_ACCOUNT" -n "$NAMESPACE"
    echo "Service account '$SERVICE_ACCOUNT' created in namespace '$NAMESPACE'."
fi


# Grant cluster-admin priviledges to the webadmin service account
kubectl create clusterrolebinding webadmin-sa-crb --clusterrole=cluster-admin --serviceaccount=kubernetes-dashboard:webadmin

# Create access token
kubectl create token webadmin -n kubernetes-dashboard > ./logs/pass_token.log

# Expose 30443 port for the service
kubectl patch svc kubernetes-dashboard -n kubernetes-dashboard --type='json' -p '[{"op":"replace","path":"/spec/type","value":"NodePort"},{"op":"replace","path":"/spec/ports/0/nodePort","value":30443}]'


# Getting a skip login option in Kubernetes Dashboard
kubectl patch deployment kubernetes-dashboard -n kubernetes-dashboard --type 'json' -p '[{"op": "add", "path": "/spec/template/spec/containers/0/args/-", "value": "--enable-skip-login"}]'

