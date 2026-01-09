#!/bin/bash
set -e

echo "Installing Istio CLI..."
curl -L https://istio.io/downloadIstio | sh -
cd istio-*
export PATH=$PWD/bin:$PATH
cd ..

echo "Installing Istio on Cluster..."
istioctl install --set profile=demo -y

echo "Labeling istio-demo namespace for injection..."
kubectl label namespace istio-demo istio-injection=enabled --overwrite

echo "Istio installed successfully."
