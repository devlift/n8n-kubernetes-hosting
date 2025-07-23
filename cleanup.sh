#!/bin/bash

# n8n Kubernetes Cleanup Script
# This script removes all n8n resources from your Kubernetes cluster

set -e  # Exit on any error

echo "🧹 Starting n8n Kubernetes cleanup..."

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

# Ask for confirmation
echo ""
print_warning "This will delete ALL n8n resources including:"
echo "  - n8n deployment and service"
echo "  - PostgreSQL deployment and service"
echo "  - All persistent volume claims (WILL DELETE DATA)"
echo "  - All secrets and configmaps"
echo "  - Ingress and SSL certificates"
echo "  - Backup schedules"
echo "  - The entire 'n8n' namespace"
echo ""
read -p "Are you sure you want to continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_status "Cleanup cancelled."
    exit 0
fi

# Delete resources in reverse order
print_status "Removing backup schedules..."
kubectl delete -f backup-schedule.yaml --ignore-not-found=true

print_status "Removing SSL certificates..."
kubectl delete -f ssl-certificate.yaml --ignore-not-found=true

print_status "Removing ingress..."
kubectl delete -f ingress.yaml --ignore-not-found=true

print_status "Removing n8n service..."
kubectl delete -f n8n-service.yaml --ignore-not-found=true

print_status "Removing n8n deployment..."
kubectl delete -f n8n-deployment.yaml --ignore-not-found=true

print_status "Removing n8n persistent volume claims..."
kubectl delete -f n8n-claim0-persistentvolumeclaim.yaml --ignore-not-found=true

print_status "Removing PostgreSQL service..."
kubectl delete -f postgres-service.yaml --ignore-not-found=true

print_status "Removing PostgreSQL deployment..."
kubectl delete -f postgres-deployment.yaml --ignore-not-found=true

print_status "Removing PostgreSQL persistent volume claims..."
kubectl delete -f postgres-claim0-persistentvolumeclaim.yaml --ignore-not-found=true

print_status "Removing PostgreSQL configmap..."
kubectl delete -f postgres-configmap.yaml --ignore-not-found=true

print_status "Removing storage configuration..."
kubectl delete -f storage.yaml --ignore-not-found=true

print_status "Removing secrets..."
kubectl delete -f n8n-secret.yaml --ignore-not-found=true
kubectl delete -f postgres-secret.yaml --ignore-not-found=true

print_status "Removing namespace..."
kubectl delete -f namespace.yaml --ignore-not-found=true

# Wait for namespace deletion
print_status "Waiting for namespace deletion to complete..."
kubectl wait --for=delete namespace/n8n --timeout=300s 2>/dev/null || true

echo ""
print_status "🎉 Cleanup completed successfully!"
echo ""
print_warning "Note: If you had persistent volumes, they may still exist and need manual cleanup."
echo "Check with: kubectl get pv" 