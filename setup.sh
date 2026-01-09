#!/bin/bash
set -e

echo "Starting full setup..."

# 1. Terraform
echo "Applying Terraform (make sure you have AWS creds)..."
cd terraform
terraform init
terraform apply -auto-approve
cd ..

# 2. Config kubectl
REGION=$(terraform -chdir=terraform output -raw region)
CLUSTER_NAME=$(terraform -chdir=terraform output -raw cluster_name)
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME

# 3. Istio
./scripts/install_istio.sh

# 4. Build Images (Optional, requires Docker)
# ./scripts/build_images.sh 

# 5. Deploy Apps
# export IMAGE_REPO=...
./scripts/deploy_apps.sh

# 6. Istio Configs
./scripts/apply_istio_config.sh

# 7. Observability
./scripts/observability.sh

echo "Setup Complete!"
