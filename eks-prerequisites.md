# EKS Deployment Prerequisites

## Required Tools
1. **AWS CLI** - Configure with appropriate permissions
2. **kubectl** - Kubernetes command-line tool
3. **helm** - Kubernetes package manager
4. **docker** - Container runtime

## AWS Permissions Required
Your AWS user/role needs these permissions:
- EKS cluster access
- ECR repository management
- ALB creation and management
- VPC and security group management

## Pre-deployment Steps

### 1. Create EKS Cluster
```bash
eksctl create cluster --name fullstack-app-cluster --region us-west-2 --nodes 2 --node-type t3.medium
```

### 2. Configure kubectl
```bash
aws eks update-kubeconfig --region us-west-2 --name fullstack-app-cluster
```

### 3. Install AWS Load Balancer Controller
```bash
# Create IAM role for ALB controller
eksctl create iamserviceaccount \
  --cluster=fullstack-app-cluster \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess \
  --override-existing-serviceaccounts \
  --approve

# Install ALB controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=fullstack-app-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller
```

### 4. Update deploy-to-eks.sh
Replace `<YOUR_AWS_ACCOUNT_ID>` with your actual AWS account ID in the deployment script.

## Estimated Costs
- EKS Cluster: ~$73/month
- EC2 nodes (2 x t3.medium): ~$60/month
- ALB: ~$20/month
- **Total: ~$153/month**