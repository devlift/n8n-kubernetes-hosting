
# n8n Kubernetes Hosting

A complete Kubernetes deployment setup for self-hosting n8n with PostgreSQL database.

## Features

- 🚀 **Complete n8n deployment** with PostgreSQL database
- 🔒 **Secure configuration** with Kubernetes secrets
- 💾 **Persistent storage** for n8n data and PostgreSQL
- 🔄 **Automated backups** with scheduled cron jobs
- 🌐 **Ingress configuration** for external access
- 📊 **Monitoring ready** with proper resource limits

## Prerequisites

- Kubernetes cluster (GKE, EKS, AKS, or local like minikube)
- `kubectl` configured to access your cluster
- Basic knowledge of Kubernetes concepts

## Quick Start

1. **Fork this repository** to your own GitHub account
2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/n8n-kubernetes-hosting.git
   cd n8n-kubernetes-hosting
   ```

3. **Customize the configuration:**
   - Update `n8n-secret.yaml` with your webhook URL
   - Modify `postgres-secret.yaml` with your database credentials
   - Adjust resource limits in `n8n-deployment.yaml` if needed

4. **Deploy to your cluster:**
   ```bash
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

5. **Access n8n:**
   - Get your external IP: `kubectl get service -n n8n n8n`
   - Open your browser to `http://EXTERNAL_IP:5678`

## Configuration Files

- `n8n-deployment.yaml` - Main n8n application deployment
- `postgres-deployment.yaml` - PostgreSQL database deployment
- `n8n-secret.yaml` - n8n configuration secrets
- `postgres-secret.yaml` - Database credentials
- `ingress.yaml` - Ingress configuration for external access
- `backup-schedule.yaml` - Automated database backups
- `storage.yaml` - Storage class configuration

## Updating n8n

To update to the latest version:

1. Update the image tag in `n8n-deployment.yaml`:
   ```yaml
   image: n8nio/n8n:1.103.2  # Change to latest version
   ```

2. Apply the changes:
   ```bash
   kubectl apply -f n8n-deployment.yaml
   ```

3. Monitor the rollout:
   ```bash
   kubectl get pods -n n8n
   kubectl rollout status deployment/n8n -n n8n
   ```

## Customization

### Custom Docker Image
If you need custom packages or modifications, use the `custom-n8n/Dockerfile`:

1. Build your custom image:
   ```bash
   cd custom-n8n
   docker build -t your-registry/n8n-custom:latest .
   docker push your-registry/n8n-custom:latest
   ```

2. Update `n8n-deployment.yaml` to use your custom image:
   ```yaml
   image: your-registry/n8n-custom:latest
   ```

### Environment Variables
Add custom environment variables in `n8n-deployment.yaml`:

```yaml
env:
  - name: N8N_CUSTOM_VAR
    value: "your-value"
```

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n n8n
kubectl describe pod -n n8n <pod-name>
```

### View Logs
```bash
kubectl logs -n n8n <pod-name>
kubectl logs -n n8n <pod-name> -f  # Follow logs
```

### Check Services
```bash
kubectl get services -n n8n
kubectl describe service -n n8n n8n
```

## Security Considerations

- Change default passwords in `postgres-secret.yaml`
- Use HTTPS in production (configure SSL certificates)
- Restrict network access with proper firewall rules
- Regularly update n8n and base images
- Monitor resource usage and logs

## Contributing

1. Fork this repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the same license as n8n. See the [LICENSE](LICENSE) file for details.

## Support

- [n8n Documentation](https://docs.n8n.io/)
- [n8n Community Forum](https://community.n8n.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

