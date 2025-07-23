#!/bin/bash

# n8n Kubernetes Deployment Script
# This script deploys n8n with PostgreSQL to your Kubernetes cluster

set -e  # Exit on any error

echo "🚀 Starting n8n Kubernetes deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we can connect to the cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Please check your kubectl configuration."
    exit 1
fi

print_status "Connected to Kubernetes cluster: $(kubectl config current-context)"

# Create namespace first
print_status "Creating namespace..."
kubectl apply -f namespace.yaml

# Apply secrets
print_status "Applying secrets..."
kubectl apply -f postgres-secret.yaml
kubectl apply -f n8n-secret.yaml

# Apply storage
print_status "Applying storage configuration..."
kubectl apply -f storage.yaml

# Apply PostgreSQL resources
print_status "Deploying PostgreSQL..."
kubectl apply -f postgres-configmap.yaml
kubectl apply -f postgres-claim0-persistentvolumeclaim.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml

# Wait for PostgreSQL to be ready
print_status "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l service=postgres -n n8n --timeout=300s

# Apply n8n resources
print_status "Deploying n8n..."
kubectl apply -f n8n-claim0-persistentvolumeclaim.yaml
kubectl apply -f n8n-deployment.yaml
kubectl apply -f n8n-service.yaml

# Apply ingress and SSL (optional)
print_status "Applying ingress and SSL configuration..."
kubectl apply -f ingress.yaml
kubectl apply -f ssl-certificate.yaml

# Apply backup schedule
print_status "Setting up automated backups..."
kubectl apply -f backup-schedule.yaml

# Wait for n8n to be ready
print_status "Waiting for n8n to be ready..."
kubectl wait --for=condition=ready pod -l service=n8n -n n8n --timeout=300s

# Get service information
print_status "Getting service information..."
kubectl get service -n n8n n8n

echo ""
print_status "🎉 Deployment completed successfully!"
echo ""
print_status "To access n8n:"
echo "  1. Get your external IP: kubectl get service -n n8n n8n"
echo "  2. Open your browser to: http://EXTERNAL_IP:5678"
echo ""
print_status "Useful commands:"
echo "  - Check pod status: kubectl get pods -n n8n"
echo "  - View logs: kubectl logs -n n8n <pod-name>"
echo "  - Check services: kubectl get services -n n8n"
echo "  - Monitor deployment: kubectl rollout status deployment/n8n -n n8n"
echo ""
print_warning "Remember to:"
echo "  - Change default passwords in postgres-secret.yaml"
echo "  - Configure SSL certificates for production use"
echo "  - Set up proper monitoring and alerting" 