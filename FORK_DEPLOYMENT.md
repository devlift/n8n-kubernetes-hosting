# How to Deploy This n8n Setup to Your Own Fork

This guide will walk you through forking this repository and deploying n8n to your own Kubernetes cluster.

## Step 1: Fork the Repository

1. **Go to the original repository** on GitHub
2. **Click the "Fork" button** in the top right corner
3. **Choose your GitHub account** as the destination
4. **Wait for the fork to complete**

## Step 2: Clone Your Fork

```bash
# Replace YOUR_USERNAME with your actual GitHub username
git clone https://github.com/YOUR_USERNAME/n8n-kubernetes-hosting.git
cd n8n-kubernetes-hosting

# Optional: Add the original as upstream for future updates
git remote add upstream https://github.com/n8n-io/n8n-kubernetes-hosting.git
```

## Step 3: Customize Configuration

### 3.1 Update Secrets

**Generate secure passwords and update `postgres-secret.yaml`:**

```bash
# Generate a secure password
openssl rand -base64 32

# Base64 encode it for Kubernetes
echo -n "your-secure-password" | base64
```

**Update `n8n-secret.yaml` with your webhook URL:**

```bash
# If you have a domain, use it
echo -n "https://your-domain.com" | base64

# Or use your cluster's external IP
echo -n "http://YOUR_EXTERNAL_IP:5678" | base64
```

### 3.2 Customize Resource Limits

Edit `n8n-deployment.yaml` and adjust resource limits based on your cluster capacity:

```yaml
resources:
  requests:
    memory: "250Mi"    # Minimum memory
    cpu: "100m"        # Minimum CPU
  limits:
    memory: "1280Mi"   # Maximum memory
    cpu: "1000m"       # Maximum CPU (1 core)
```

### 3.3 Update Ingress (Optional)

If you have a domain, update `ingress.yaml`:

```yaml
spec:
  rules:
  - host: your-domain.com  # Replace with your domain
```

## Step 4: Deploy to Your Cluster

### Option A: Use the Deployment Script (Recommended)

```bash
# Make sure the script is executable
chmod +x deploy.sh

# Run the deployment
./deploy.sh
```

### Option B: Manual Deployment

```bash
# Apply resources in order
kubectl apply -f namespace.yaml
kubectl apply -f postgres-secret.yaml
kubectl apply -f n8n-secret.yaml
kubectl apply -f storage.yaml
kubectl apply -f postgres-configmap.yaml
kubectl apply -f postgres-claim0-persistentvolumeclaim.yaml
kubectl apply -f postgres-deployment.yaml
kubectl apply -f postgres-service.yaml
kubectl apply -f n8n-claim0-persistentvolumeclaim.yaml
kubectl apply -f n8n-deployment.yaml
kubectl apply -f n8n-service.yaml
kubectl apply -f ingress.yaml
kubectl apply -f ssl-certificate.yaml
kubectl apply -f backup-schedule.yaml
```

## Step 5: Access Your n8n Instance

```bash
# Get your external IP
kubectl get service -n n8n n8n

# Open your browser to: http://EXTERNAL_IP:5678
```

## Step 6: Verify Deployment

```bash
# Check pod status
kubectl get pods -n n8n

# Check services
kubectl get services -n n8n

# View logs if needed
kubectl logs -n n8n <pod-name>
```

## Customization Options

### Custom Docker Image

If you need custom packages or modifications:

1. **Edit `custom-n8n/Dockerfile`:**
   ```dockerfile
   FROM n8nio/n8n:1.103.2
   
   USER root
   # Add your custom packages
   RUN apk add --no-cache your-package
   
   USER node
   ```

2. **Build and push your image:**
   ```bash
   cd custom-n8n
   docker build -t your-registry/n8n-custom:latest .
   docker push your-registry/n8n-custom:latest
   ```

3. **Update `n8n-deployment.yaml`:**
   ```yaml
   image: your-registry/n8n-custom:latest
   ```

### Environment Variables

Add custom environment variables in `n8n-deployment.yaml`:

```yaml
env:
  - name: N8N_CUSTOM_VAR
    value: "your-value"
  - name: N8N_ENCRYPTION_KEY
    valueFrom:
      secretKeyRef:
        name: n8n-secret
        key: ENCRYPTION_KEY
```

## Updating n8n

To update to the latest version:

1. **Check the latest version:**
   ```bash
   curl -s https://api.github.com/repos/n8n-io/n8n/releases/latest | grep '"tag_name"' | cut -d'"' -f4
   ```

2. **Update the image tag in `n8n-deployment.yaml`:**
   ```yaml
   image: n8nio/n8n:1.103.2  # Change to latest version
   ```

3. **Apply the changes:**
   ```bash
   kubectl apply -f n8n-deployment.yaml
   ```

4. **Monitor the rollout:**
   ```bash
   kubectl rollout status deployment/n8n -n n8n
   ```

## Troubleshooting

### Common Issues

**Pod stuck in Pending:**
```bash
kubectl describe pod -n n8n <pod-name>
```

**Pod stuck in PodInitializing:**
```bash
kubectl logs -n n8n <pod-name> -c volume-permissions
```

**n8n not starting:**
```bash
kubectl logs -n n8n <pod-name> -c n8n
```

**Database connection issues:**
```bash
kubectl logs -n n8n <postgres-pod-name>
```

### Useful Commands

```bash
# Check all resources
kubectl get all -n n8n

# Check persistent volumes
kubectl get pv

# Check events
kubectl get events -n n8n --sort-by='.lastTimestamp'

# Port forward for debugging
kubectl port-forward -n n8n svc/n8n 5678:5678
```

## Cleanup

To remove all n8n resources:

```bash
# Use the cleanup script
./cleanup.sh

# Or manually delete everything
kubectl delete namespace n8n
```

## Security Considerations

1. **Change default passwords** in `postgres-secret.yaml`
2. **Use HTTPS** in production (configure SSL certificates)
3. **Restrict network access** with proper firewall rules
4. **Regularly update** n8n and base images
5. **Monitor resource usage** and logs
6. **Set up proper backups** and test restore procedures

## Support

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## Contributing Back

If you make improvements:

1. **Create a feature branch:**
   ```bash
   git checkout -b feature/your-improvement
   ```

2. **Make your changes and test them**

3. **Commit and push:**
   ```bash
   git add .
   git commit -m "Add your improvement"
   git push origin feature/your-improvement
   ```

4. **Create a pull request** to the original repository

---

**Happy automating with n8n! 🚀** 