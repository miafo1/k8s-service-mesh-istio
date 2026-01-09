#!/bin/bash
set -e

echo "Adding Helm Repos..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "Installing Prometheus & Grafana Stack..."
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace istio-system \
  --create-namespace \
  --set grafana.enabled=true \
  --set prometheus.enabled=true

echo "Installing Jaeger..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/addons/jaeger.yaml

echo "Setting up Kiali (Dashboard)..."
kubectl apply -f https://raw.githubusercontent.com/istio/istio/master/samples/addons/kiali.yaml

echo "Observability Stack Installed."
