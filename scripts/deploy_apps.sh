#!/bin/bash
set -e

# Prompt for Image Repo if not set
if [ -z "$IMAGE_REPO" ]; then
    echo "Please set IMAGE_REPO environment variable (e.g., your dockerhub username)"
    exit 1
fi

echo "Deploying Namespace..."
kubectl apply -f k8s/namespace.yaml

echo "Deploying Apps with IMAGE_REPO=$IMAGE_REPO..."
# Substitute variables and apply
for file in k8s/*.yaml; do
    if [ "$file" != "k8s/namespace.yaml" ]; then
        envsubst < $file | kubectl apply -f -
    fi
done

echo "Apps deployed."
