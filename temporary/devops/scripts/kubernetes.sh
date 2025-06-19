#!/usr/bin/env bash

echo "Cleaning up any existing resources..."
kubectl delete deployment web-server --ignore-not-found=true
kubectl delete service web-server --ignore-not-found=true

echo "Creating nginx deployment..."
kubectl create deployment web-server --image=nginx

echo "Exposing deployment as service..."
kubectl expose deployment web-server --port=8080 --type=ClusterIP

echo "Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=60s deployment/web-server

echo "Current resources:"
kubectl get deployments,services,pods

echo "=== HOW TO ACCESS ==="
echo "Port forward: kubectl port-forward service/web-server 8080:8080"
echo "Then visit: http://localhost:8080"