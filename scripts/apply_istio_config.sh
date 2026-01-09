#!/bin/bash
set -e

echo "Applying Istio Configurations..."
kubectl apply -f istio/gateway.yaml
kubectl apply -f istio/virtual-services.yaml
kubectl apply -f istio/destination-rules.yaml
kubectl apply -f istio/peer-authentication.yaml

echo "Istio Configs Applied."
