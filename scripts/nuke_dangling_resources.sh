#!/bin/bash
# scripts/nuke_dangling_resources.sh
# Purpose: Find and delete ELBs/Enis that block Terraform from destroying the VPC.

REGION="us-east-1"
CLUSTER_NAME="istio-mesh-demo"

echo "WARNING: This script will delete Load Balancers associated with cluster '$CLUSTER_NAME' in '$REGION'."
echo "This is destructive and intended to fix 'DependencyViolation' errors during teardown."
echo "----------------------------------------------------------------"

# 1. Try standard K8s deletion first (Best way)
echo "Attempting to talk to cluster to delete Services..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME 2>/dev/null

if kubectl get svc -A &>/dev/null; then
  echo "Cluster is reachable. Deleting LoadBalancer services..."
  kubectl delete svc --all-namespaces --field-selector spec.type=LoadBalancer
  echo "Waiting 45s for Cloud Controller to clean up..."
  sleep 45
else
  echo "Cluster control plane not reachable or auth failed. Proceeding to manual AWS cleanup."
fi

# 2. Find Load Balancers by Tag
echo "Searching for dangling Load Balancers (ELB/ALB/NLB) with tag 'kubernetes.io/cluster/$CLUSTER_NAME'..."

# Classic ELBs
CLBS=$(aws elb describe-load-balancers --region $REGION --query "LoadBalancerDescriptions[*].{Name:LoadBalancerName, Tags:LoadBalancerName}" --output text | xargs -I {} sh -c "aws elb describe-tags --region $REGION --load-balancer-names {} --query \"TagDescriptions[?Tags[?Key=='kubernetes.io/cluster/$CLUSTER_NAME']].LoadBalancerName\" --output text")

if [ ! -z "$CLBS" ]; then
    for lb in $CLBS; do
       echo "Deleting Classic LB: $lb"
       aws elb delete-load-balancer --region $REGION --load-balancer-name $lb
    done
else
    echo "No matching Classic ELBs found."
fi

# API v2 LBs (ALB/NLB) - Searching by Tag is harder in CLI one-liner, iterating...
# Note: Resource Groups Tagging API is better but keeping it simple with assuming recent LBs.
# Simpler approach: List all LBs, get tags, check for cluster tag.
echo "Checking v2 Load Balancers..."
LBS_ARNS=$(aws elbv2 describe-load-balancers --region $REGION --query "LoadBalancers[*].LoadBalancerArn" --output text)

for arn in $LBS_ARNS; do
    TAGS=$(aws elbv2 describe-tags --resource-arns $arn --region $REGION --query "TagDescriptions[0].Tags")
    # Check if tags contain our cluster
    if echo "$TAGS" | grep -q "$CLUSTER_NAME"; then
        echo "Deleting LB: $arn"
        aws elbv2 delete-load-balancer --load-balancer-arn $arn --region $REGION
        # Wait a bit for ENIs to release
        sleep 5
    fi
done

echo "----------------------------------------------------------------"
echo "Cleanup passed. Please run 'terraform destroy' again."
