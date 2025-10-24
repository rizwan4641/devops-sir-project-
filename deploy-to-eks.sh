#!/bin/bash

# EKS Deployment Script for ReactJS-Spring-Boot CRUD App
# Prerequisites: AWS CLI, kubectl, helm, docker configured

set -e

# Configuration
AWS_REGION="us-west-2"
CLUSTER_NAME="fullstack-app-cluster"
ECR_REGISTRY="<YOUR_AWS_ACCOUNT_ID>.dkr.ecr.${AWS_REGION}.amazonaws.com"
BACKEND_REPO="springboot-backend"
FRONTEND_REPO="react-frontend"

echo "🚀 Starting EKS deployment process..."

# 1. Create ECR repositories
echo "📦 Creating ECR repositories..."
aws ecr create-repository --repository-name $BACKEND_REPO --region $AWS_REGION || true
aws ecr create-repository --repository-name $FRONTEND_REPO --region $AWS_REGION || true

# 2. Login to ECR
echo "🔐 Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# 3. Build and push backend image
echo "🏗️ Building and pushing backend image..."
cd springboot-backend
docker build -t $BACKEND_REPO:latest .
docker tag $BACKEND_REPO:latest $ECR_REGISTRY/$BACKEND_REPO:latest
docker push $ECR_REGISTRY/$BACKEND_REPO:latest
cd ..

# 4. Build and push frontend image
echo "🏗️ Building and pushing frontend image..."
cd react-frontend
docker build -t $FRONTEND_REPO:latest .
docker tag $FRONTEND_REPO:latest $ECR_REGISTRY/$FRONTEND_REPO:latest
docker push $ECR_REGISTRY/$FRONTEND_REPO:latest
cd ..

# 5. Update Helm values with ECR image URLs
echo "⚙️ Updating Helm values..."
sed -i "s|springboot-backend:latest|$ECR_REGISTRY/$BACKEND_REPO:latest|g" helm-chart/values.yaml
sed -i "s|react-frontend:latest|$ECR_REGISTRY/$FRONTEND_REPO:latest|g" helm-chart/values.yaml

# 6. Install AWS Load Balancer Controller (if not already installed)
echo "🔧 Installing AWS Load Balancer Controller..."
kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master" || true

# 7. Deploy application using Helm
echo "🚀 Deploying application to EKS..."
helm upgrade --install fullstack-app ./helm-chart --namespace default

echo "✅ Deployment completed!"
echo "📋 Next steps:"
echo "1. Wait for ALB to be provisioned (5-10 minutes)"
echo "2. Get ALB URL: kubectl get ingress fullstack-app-ingress"
echo "3. Access your application via the ALB URL"