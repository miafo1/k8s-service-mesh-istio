#!/bin/bash
set -e

if [ -z "$IMAGE_REPO" ]; then
    echo "Error: IMAGE_REPO environment variable is not set."
    echo "Usage: export IMAGE_REPO=your-dockerhub-username"
    exit 1
fi

echo "Building and Pushing images to $IMAGE_REPO..."

# Services to build
SERVICES="frontend product order"

for svc in $SERVICES; do
    echo "------------------------------------------------"
    echo "Processing $svc..."
    
    # Navigate to app dir
    cd apps/$svc
    
    # Build
    # Note: product-service has strict v1 tag, but for v2 we use same image with different env var configuration in k8s
    # In a real scenario, we might have different code. Here we use 'v1' for all initial builds.
    docker build -t $IMAGE_REPO/$svc-service:v1 . --platform linux/amd64
    
    # Push
    docker push $IMAGE_REPO/$svc-service:v1
    
    # Specific handling for frontend (naming convention difference in folder vs image in my deploy_apps.sh? let's check)
    # k8s/frontend.yaml uses image: ${IMAGE_REPO}/frontend:v1
    # k8s/product.yaml uses image: ${IMAGE_REPO}/product-service:v1
    # k8s/order.yaml uses image: ${IMAGE_REPO}/order-service:v1
    
    # Fix naming if needed. 
    # Folder: apps/frontend -> Image: frontend:v1
    # Folder: apps/product -> Image: product-service:v1
    # Folder: apps/order -> Image: order-service:v1
    
    # Let's adjust tags to match K8s manifests exactly
    if [ "$svc" == "frontend" ]; then
        docker tag $IMAGE_REPO/$svc-service:v1 $IMAGE_REPO/frontend:v1
        docker push $IMAGE_REPO/frontend:v1
    fi
    
    cd ../..
done

echo "------------------------------------------------"
echo "All images built and pushed successfully!"
