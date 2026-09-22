# Kubernetes Deployment Guide for Rancher Desktop
# ================================================

## Prerequisites

Before deploying, ensure you have:
1. Rancher Desktop installed and running
2. `kubectl` configured (usually automatic with Rancher Desktop)
3. Access to the Docker images (they will be pulled from Docker Hub)

## Check kubectl connection

```bash
kubectl cluster-info
kubectl get nodes
```

## Directory Structure

```
kubernetes/
├── 01-namespace.yaml              # Create isolated namespace
├── 02-secrets.yaml                # Database credentials
├── 03-configmap.yaml              # Application configuration
├── 04-storage.yaml                # PersistentVolume & PersistentVolumeClaim
├── 05-mysql-statefulset.yaml      # MySQL StatefulSet (preserves identity)
├── 06-springboot-deployment.yaml  # Spring Boot Backend Deployment
├── 07-springboot-service.yaml     # Spring Boot Service (ClusterIP)
├── 08-react-deployment.yaml       # React Frontend Deployment
├── 09-react-service.yaml          # React Service (NodePort)
├── 10-daemonset.yaml              # Example DaemonSet
└── 11-replicaset-example.yaml     # Example ReplicaSet (informational)
```

## Kubernetes Objects Explanation

### 1. Namespace (01-namespace.yaml)
- Isolates resources in a virtual cluster
- Name: `tutorial-app`
- Allows multiple applications to run without conflicts

### 2. Secrets (02-secrets.yaml)
- Stores sensitive data (base64 encoded)
- Contains MySQL root password and Spring Boot database credentials
- **IMPORTANT**: Change the base64 encoded values before deploying to production

### 3. ConfigMap (03-configmap.yaml)
- Stores non-sensitive configuration data
- Contains Spring Boot settings and Nginx configuration
- Can be updated without restarting pods

### 4. PersistentVolume & PersistentVolumeClaim (04-storage.yaml)
- PV: Cluster-level storage resource (10Gi for MySQL data)
- PVC: Request for storage by pods
- Ensures data persists even when pods are deleted
- Using local storage (suitable for Rancher Desktop on local machine)

### 5. StatefulSet (05-mysql-statefulset.yaml)
- Maintains stable pod identity and ordering
- Ideal for stateful applications like databases
- Pods get predictable names: mysql-database-0, mysql-database-1, etc.
- Uses headless service for direct pod communication

### 6. Deployment (06-springboot-deployment.yaml & 08-react-deployment.yaml)
- Creates and manages Pods and ReplicaSets
- Automatically creates a ReplicaSet with specified replicas
- Supports rolling updates and rollbacks
- Spring Boot: 2 replicas for redundancy
- React: 2 replicas behind load balancer

### 7. ReplicaSet (11-replicaset-example.yaml)
- Ensures specified number of pod replicas are running
- Automatically replaces failed pods
- Usually managed by Deployment (don't create directly)

### 8. Services (07-springboot-service.yaml & 09-react-service.yaml)
- Exposes pods to network
- Types:
  - ClusterIP: Internal communication only (Spring Boot)
  - NodePort: Accessible from outside cluster on port 30080 (React)
  - LoadBalancer: Cloud provider integrates (alternative)

### 9. DaemonSet (10-daemonset.yaml)
- Runs one pod per node automatically
- Use cases: monitoring, logging, networking agents
- In our example: node-monitor runs on all nodes

## Step-by-Step Deployment

### Step 1: Update Secrets (IMPORTANT!)
Edit `02-secrets.yaml` and update the base64 encoded values:

```bash
# To encode a value to base64:
echo -n 'your-password' | base64

# For example, to change mysql password to 'mypassword123':
# echo -n 'mypassword123' | base64  -> bXlwYXNzd29yZDEyMw==
```

Update these values in secrets.yaml:
- `mysql-root-password`: Your MySQL password (currently 123456)
- `datasource-password`: Spring Boot datasource password (currently 123456)

### Step 2: Create Namespace
```bash
kubectl apply -f kubernetes/01-namespace.yaml

# Verify
kubectl get namespaces
```

### Step 3: Create Secrets
```bash
kubectl apply -f kubernetes/02-secrets.yaml

# Verify
kubectl get secrets -n tutorial-app
kubectl describe secret mysql-credentials -n tutorial-app
```

### Step 4: Create ConfigMap
```bash
kubectl apply -f kubernetes/03-configmap.yaml

# Verify
kubectl get configmaps -n tutorial-app
kubectl describe configmap app-config -n tutorial-app
```

### Step 5: Create Storage (PV & PVC)
```bash
kubectl apply -f kubernetes/04-storage.yaml

# Verify
kubectl get pv
kubectl get pvc -n tutorial-app
kubectl describe pvc mysql-pvc -n tutorial-app
```

### Step 6: Deploy MySQL StatefulSet
```bash
kubectl apply -f kubernetes/05-mysql-statefulset.yaml

# Verify (wait for pod to be ready)
kubectl get statefulsets -n tutorial-app
kubectl get pods -n tutorial-app
kubectl logs -f mysql-database-0 -n tutorial-app
```

### Step 7: Deploy Spring Boot Backend
```bash
kubectl apply -f kubernetes/07-springboot-service.yaml
kubectl apply -f kubernetes/06-springboot-deployment.yaml

# Verify
kubectl get deployments -n tutorial-app
kubectl get pods -n tutorial-app
kubectl logs -f deployment/springboot-api -n tutorial-app
```

### Step 8: Deploy React Frontend
```bash
kubectl apply -f kubernetes/09-react-service.yaml
kubectl apply -f kubernetes/08-react-deployment.yaml

# Verify
kubectl get service -n tutorial-app
kubectl get pods -n tutorial-app
```

### Step 9: (Optional) Deploy DaemonSet
```bash
kubectl apply -f kubernetes/10-daemonset.yaml

# Verify
kubectl get daemonsets -n tutorial-app
kubectl get pods -n tutorial-app -l app=node-monitor
```

## Quick Deployment (All at once)

If all secrets and configs are correct, deploy everything:

```bash
kubectl apply -f kubernetes/

# Verify all resources
kubectl get all -n tutorial-app
```

## Access Your Application

### Option 1: NodePort Service (React Frontend)
1. Find your machine's IP (usually localhost for Rancher Desktop)
2. Open browser: `http://localhost:30080`

### Option 2: Port Forward
```bash
# Forward React
kubectl port-forward -n tutorial-app svc/react-frontend-service 3001:80

# Open browser: http://localhost:3001
```

```bash
# Forward Spring Boot API
kubectl port-forward -n tutorial-app svc/springboot-api-service 8080:8080

# Test API: http://localhost:8080
```

### Option 3: Using kubectl proxy
```bash
kubectl proxy

# Access via: http://localhost:8001/api/v1/namespaces/tutorial-app/services/react-frontend-service/proxy/
```

## Verify Deployment

```bash
# Check all resources in namespace
kubectl get all -n tutorial-app

# Check pod status
kubectl get pods -n tutorial-app
kubectl describe pods -n tutorial-app

# Check services
kubectl get svc -n tutorial-app
kubectl describe svc react-frontend-service -n tutorial-app

# Check StatefulSet
kubectl get statefulsets -n tutorial-app
kubectl get pvc -n tutorial-app

# Check ReplicaSet (created by Deployment)
kubectl get replicasets -n tutorial-app

# View logs
kubectl logs -n tutorial-app deployment/springboot-api
kubectl logs -n tutorial-app deployment/react-frontend
kubectl logs -n tutorial-app statefulset/mysql-database
```

## Scaling Resources

### Scale Spring Boot Deployment
```bash
kubectl scale deployment springboot-api -n tutorial-app --replicas=3
```

### Scale React Frontend
```bash
kubectl scale deployment react-frontend -n tutorial-app --replicas=4
```

### Verify scaling
```bash
kubectl get pods -n tutorial-app
```

## Update Docker Images

### Update Spring Boot to newer version
```bash
kubectl set image deployment/springboot-api \
  springboot-api=bezkoder/spring-boot-tutorials:v2 \
  -n tutorial-app
```

### Rollback if update fails
```bash
kubectl rollout undo deployment/springboot-api -n tutorial-app
```

### Check rollout status
```bash
kubectl rollout status deployment/springboot-api -n tutorial-app
```

## Monitoring & Debugging

### Check events
```bash
kubectl get events -n tutorial-app --sort-by='.lastTimestamp'
```

### Describe resources
```bash
kubectl describe pod springboot-api-xxxxx -n tutorial-app
kubectl describe statefulset mysql-database -n tutorial-app
kubectl describe pvc mysql-pvc -n tutorial-app
```

### Execute commands in pod
```bash
# Shell into Spring Boot pod
kubectl exec -it deployment/springboot-api -n tutorial-app -- /bin/bash

# Shell into MySQL pod
kubectl exec -it mysql-database-0 -n tutorial-app -- mysql -u root -p
```

### View resource usage
```bash
kubectl top nodes
kubectl top pods -n tutorial-app
```

## Delete/Cleanup

### Delete specific resource
```bash
kubectl delete deployment springboot-api -n tutorial-app
kubectl delete statefulset mysql-database -n tutorial-app
```

### Delete entire namespace (WARNING: Deletes everything in namespace)
```bash
kubectl delete namespace tutorial-app
```

### Delete all manifests
```bash
kubectl delete -f kubernetes/ --namespace=tutorial-app
```

## Troubleshooting

### Pod stuck in Pending
- Check PVC status: `kubectl describe pvc mysql-pvc -n tutorial-app`
- Check events: `kubectl get events -n tutorial-app`
- For local storage PV: Ensure `/var/lib/mysql-data` directory exists with proper permissions

### Pod CrashLoopBackOff
- Check logs: `kubectl logs -n tutorial-app pod-name`
- Most common: MySQL not ready, database connectivity issues

### Service not accessible
- Verify service: `kubectl describe svc react-frontend-service -n tutorial-app`
- Check endpoints: `kubectl get endpoints -n tutorial-app`
- Verify pods are running: `kubectl get pods -n tutorial-app`

### MySQL connection issues
- Verify StatefulSet is running: `kubectl get statefulset -n tutorial-app`
- Check MySQL logs: `kubectl logs mysql-database-0 -n tutorial-app`
- Test connectivity: `kubectl run -it --rm debug --image=mysql:8.0 --restart=Never -- mysql -hmysql-database -uroot -p123456`

## Best Practices

1. **Security**:
   - Update Secret values before production deployment
   - Use RBAC for access control
   - Consider sealed-secrets or external secret managers

2. **Storage**:
   - For production, use cloud storage (AWS EBS, GCP PD, etc.)
   - Current setup uses local storage, suitable for development only

3. **Resource Management**:
   - Set resource requests and limits (already done in manifests)
   - Monitor cluster resource usage

4. **Updates**:
   - Use rolling updates (default in Deployment)
   - Test in development namespace first

5. **Backup**:
   - Regularly backup database using: `kubectl exec mysql-database-0 -n tutorial-app -- mysqldump -u root -p123456 testdb > backup.sql`

## Additional Resources

- Kubernetes Documentation: https://kubernetes.io/docs/
- Rancher Desktop: https://rancherdesktop.io/
- kubectl cheat sheet: https://kubernetes.io/docs/reference/kubectl/cheatsheet/
