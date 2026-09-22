#!/bin/bash

# Kubernetes Deployment Script for Rancher Desktop
# This script deploys the Spring Boot + React + MySQL application

set -e

NAMESPACE="tutorial-app"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_step() {
  echo -e "${BLUE}▶ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Check if kubectl is available
check_kubectl() {
  if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
  fi
  print_success "kubectl found"
}

# Check cluster connection
check_cluster() {
  print_step "Checking Kubernetes cluster connection..."
  if ! kubectl cluster-info &> /dev/null; then
    print_error "Cannot connect to Kubernetes cluster. Ensure Rancher Desktop is running."
    exit 1
  fi
  print_success "Connected to Kubernetes cluster"
}

# Deploy resources
deploy_resources() {
  print_step "Deploying Kubernetes resources..."
  
  # Create namespace
  print_step "Creating namespace..."
  kubectl apply -f "$SCRIPT_DIR/01-namespace.yaml"
  print_success "Namespace created"
  
  # Create secrets
  print_step "Creating secrets..."
  kubectl apply -f "$SCRIPT_DIR/02-secrets.yaml"
  print_success "Secrets created"
  
  # Create configmaps
  print_step "Creating configmaps..."
  kubectl apply -f "$SCRIPT_DIR/03-configmap.yaml"
  print_success "ConfigMaps created"
  
  # Create storage
  print_step "Creating persistent storage..."
  kubectl apply -f "$SCRIPT_DIR/04-storage.yaml"
  print_success "Storage created"
  
  sleep 2
  
  # Deploy MySQL
  print_step "Deploying MySQL StatefulSet (this may take a minute)..."
  kubectl apply -f "$SCRIPT_DIR/05-mysql-statefulset.yaml"
  
  # Wait for MySQL to be ready
  print_step "Waiting for MySQL to be ready..."
  kubectl wait --for=condition=ready pod -l app=mysql-database -n "$NAMESPACE" --timeout=120s 2>/dev/null || {
    print_warning "MySQL pod not ready yet, but continuing..."
  }
  print_success "MySQL deployed"
  
  sleep 2
  
  # Deploy Spring Boot API
  print_step "Deploying Spring Boot API..."
  kubectl apply -f "$SCRIPT_DIR/07-springboot-service.yaml"
  kubectl apply -f "$SCRIPT_DIR/06-springboot-deployment.yaml"
  print_success "Spring Boot API deployed"
  
  sleep 2
  
  # Deploy React Frontend
  print_step "Deploying React Frontend..."
  kubectl apply -f "$SCRIPT_DIR/09-react-service.yaml"
  kubectl apply -f "$SCRIPT_DIR/08-react-deployment.yaml"
  print_success "React Frontend deployed"
  
  # Deploy DaemonSet (optional)
  print_step "Deploying DaemonSet..."
  kubectl apply -f "$SCRIPT_DIR/10-daemonset.yaml"
  print_success "DaemonSet deployed"
}

# Verify deployment
verify_deployment() {
  print_step "Verifying deployment..."
  
  echo -e "\n${BLUE}=== Checking Resources ===${NC}"
  echo -e "\n${BLUE}Namespaces:${NC}"
  kubectl get namespaces | grep tutorial-app
  
  echo -e "\n${BLUE}Secrets:${NC}"
  kubectl get secrets -n "$NAMESPACE"
  
  echo -e "\n${BLUE}ConfigMaps:${NC}"
  kubectl get configmaps -n "$NAMESPACE"
  
  echo -e "\n${BLUE}Persistent Volumes:${NC}"
  kubectl get pv
  
  echo -e "\n${BLUE}Persistent Volume Claims:${NC}"
  kubectl get pvc -n "$NAMESPACE"
  
  echo -e "\n${BLUE}StatefulSets:${NC}"
  kubectl get statefulsets -n "$NAMESPACE"
  
  echo -e "\n${BLUE}Deployments:${NC}"
  kubectl get deployments -n "$NAMESPACE"
  
  echo -e "\n${BLUE}ReplicaSets:${NC}"
  kubectl get replicasets -n "$NAMESPACE"
  
  echo -e "\n${BLUE}Pods:${NC}"
  kubectl get pods -n "$NAMESPACE" -o wide
  
  echo -e "\n${BLUE}Services:${NC}"
  kubectl get services -n "$NAMESPACE" -o wide
  
  echo -e "\n${BLUE}DaemonSets:${NC}"
  kubectl get daemonsets -n "$NAMESPACE"
  
  print_success "Deployment verification complete"
}

# Print access information
print_access_info() {
  echo -e "\n${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║              Deployment Complete!                      ║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
  
  echo -e "\n${BLUE}Access Information:${NC}"
  echo -e "React Frontend (NodePort):  ${YELLOW}http://localhost:30080${NC}"
  echo -e "Spring Boot API (Internal): ${YELLOW}http://springboot-api-service:8080${NC}"
  echo -e "MySQL Database (Internal):  ${YELLOW}mysql-database:3306${NC}"
  
  echo -e "\n${BLUE}Port Forwarding (Alternative):${NC}"
  echo -e "Forwarding React:  ${YELLOW}kubectl port-forward -n $NAMESPACE svc/react-frontend-service 3001:80${NC}"
  echo -e "Forwarding API:    ${YELLOW}kubectl port-forward -n $NAMESPACE svc/springboot-api-service 8080:8080${NC}"
  
  echo -e "\n${BLUE}Useful Commands:${NC}"
  echo -e "View logs:         ${YELLOW}kubectl logs -f deployment/springboot-api -n $NAMESPACE${NC}"
  echo -e "Shell into pod:    ${YELLOW}kubectl exec -it deployment/springboot-api -n $NAMESPACE -- /bin/bash${NC}"
  echo -e "Watch pods:        ${YELLOW}kubectl get pods -n $NAMESPACE -w${NC}"
  echo -e "Describe pod:      ${YELLOW}kubectl describe pod POD_NAME -n $NAMESPACE${NC}"
  echo -e "\n${BLUE}For more info, see: DEPLOYMENT-GUIDE.md${NC}\n"
}

# Main execution
main() {
  echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${BLUE}║   Kubernetes Deployment for Rancher Desktop           ║${NC}"
  echo -e "${BLUE}║   Spring Boot + React + MySQL                         ║${NC}"
  echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"
  
  check_kubectl
  check_cluster
  
  print_warning "IMPORTANT: Update 02-secrets.yaml with your actual passwords before deployment!"
  print_warning "Edit the base64 encoded values in 02-secrets.yaml"
  
  read -p "Continue with deployment? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Deployment cancelled"
    exit 1
  fi
  
  deploy_resources
  
  print_step "Waiting for pods to start..."
  sleep 10
  
  verify_deployment
  print_access_info
}

# Run main function
main
