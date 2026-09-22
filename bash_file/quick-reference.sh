#!/bin/bash

# Quick Reference Script - Common kubectl commands

NAMESPACE="tutorial-app"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Kubernetes Quick Reference - Rancher Desktop   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}\n"

echo -e "${YELLOW}📋 STATUS & MONITORING:${NC}"
echo "  kubectl get all -n $NAMESPACE               # View all resources"
echo "  kubectl get pods -n $NAMESPACE -w           # Watch pods (live)"
echo "  kubectl get events -n $NAMESPACE --sort-by='.lastTimestamp'"
echo "  kubectl top pods -n $NAMESPACE              # Resource usage"

echo -e "\n${YELLOW}📝 LOGS & DEBUGGING:${NC}"
echo "  kubectl logs -f deployment/springboot-api -n $NAMESPACE         # Spring Boot logs"
echo "  kubectl logs -f deployment/react-frontend -n $NAMESPACE         # React logs"
echo "  kubectl logs -f statefulset/mysql-database -n $NAMESPACE        # MySQL logs"
echo "  kubectl logs -f daemonset/node-monitor -n $NAMESPACE            # DaemonSet logs"

echo -e "\n${YELLOW}🔍 INSPECTING RESOURCES:${NC}"
echo "  kubectl describe pod POD_NAME -n $NAMESPACE"
echo "  kubectl describe statefulset mysql-database -n $NAMESPACE"
echo "  kubectl describe pvc mysql-pvc -n $NAMESPACE"
echo "  kubectl describe deployment springboot-api -n $NAMESPACE"

echo -e "\n${YELLOW}💻 EXECUTE & SHELL:${NC}"
echo "  kubectl exec -it deployment/springboot-api -n $NAMESPACE -- /bin/bash"
echo "  kubectl exec -it mysql-database-0 -n $NAMESPACE -- mysql -u root -p"
echo "  kubectl exec -it deployment/react-frontend -n $NAMESPACE -- sh"

echo -e "\n${YELLOW}🔀 PORT FORWARDING:${NC}"
echo "  kubectl port-forward -n $NAMESPACE svc/react-frontend-service 3001:80"
echo "  kubectl port-forward -n $NAMESPACE svc/springboot-api-service 8080:8080"
echo "  kubectl port-forward -n $NAMESPACE statefulset/mysql-database 3306:3306"

echo -e "\n${YELLOW}📊 SCALING:${NC}"
echo "  kubectl scale deployment springboot-api -n $NAMESPACE --replicas=3"
echo "  kubectl scale deployment react-frontend -n $NAMESPACE --replicas=4"

echo -e "\n${YELLOW}🔄 UPDATES & ROLLBACK:${NC}"
echo "  kubectl set image deployment/springboot-api springboot-api=bezkoder/spring-boot-tutorials:v2"
echo "  kubectl rollout status deployment/springboot-api -n $NAMESPACE"
echo "  kubectl rollout undo deployment/springboot-api -n $NAMESPACE"
echo "  kubectl rollout history deployment/springboot-api -n $NAMESPACE"

echo -e "\n${YELLOW}🗑️  DELETE RESOURCES:${NC}"
echo "  kubectl delete deployment springboot-api -n $NAMESPACE"
echo "  kubectl delete statefulset mysql-database -n $NAMESPACE"
echo "  kubectl delete namespace $NAMESPACE                              # Delete entire namespace"

echo -e "\n${YELLOW}🕵️ TROUBLESHOOTING:${NC}"
echo "  kubectl get pods -n $NAMESPACE -o wide                           # See pod details"
echo "  kubectl describe pod POD_NAME -n $NAMESPACE                      # Detailed pod info"
echo "  kubectl get pvc -n $NAMESPACE                                   # Check PVC status"
echo "  kubectl get replicasets -n $NAMESPACE                           # Check ReplicaSets"
echo "  kubectl get daemonsets -n $NAMESPACE                            # Check DaemonSets"

echo -e "\n${YELLOW}🌐 SERVICES & ENDPOINTS:${NC}"
echo "  kubectl get svc -n $NAMESPACE                                   # List all services"
echo "  kubectl get endpoints -n $NAMESPACE                             # View endpoints"
echo "  kubectl describe svc springboot-api-service -n $NAMESPACE"
echo "  kubectl describe svc react-frontend-service -n $NAMESPACE"

echo -e "\n${YELLOW}📦 STORAGE:${NC}"
echo "  kubectl get pv                                                  # Persistent volumes"
echo "  kubectl get pvc -n $NAMESPACE                                   # Persistent volume claims"
echo "  kubectl describe pvc mysql-pvc -n $NAMESPACE                    # PVC details"

echo -e "\n${YELLOW}🔐 SECRETS & CONFIG:${NC}"
echo "  kubectl get secrets -n $NAMESPACE"
echo "  kubectl get configmaps -n $NAMESPACE"
echo "  kubectl describe secret mysql-credentials -n $NAMESPACE"

echo -e "\n${YELLOW}🔌 CLUSTER INFO:${NC}"
echo "  kubectl cluster-info"
echo "  kubectl get nodes"
echo "  kubectl describe node NODE_NAME"

echo -e "\n${GREEN}ℹ️  For detailed guide, see: DEPLOYMENT-GUIDE.md${NC}\n"
