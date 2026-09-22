#!/bin/bash

# Cleanup Script - Remove all deployed resources

set -e

NAMESPACE="tutorial-app"

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

print_warning() {
  echo -e "${YELLOW}⚠ $1${NC}"
}

print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Main cleanup
main() {
  echo -e "${RED}╔════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║                  CLEANUP WARNING                      ║${NC}"
  echo -e "${RED}║          This will delete all deployments             ║${NC}"
  echo -e "${RED}║       and the tutorial-app namespace entirely!        ║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════╝${NC}\n"
  
  print_warning "This action is IRREVERSIBLE. Confirm if you want to continue."
  read -p "Type 'DELETE' to confirm: " confirmation
  
  if [ "$confirmation" != "DELETE" ]; then
    print_error "Cleanup cancelled"
    exit 1
  fi
  
  echo -e "\n${YELLOW}Deleting resources...${NC}"
  
  # Delete namespace (this deletes everything in it)
  kubectl delete namespace $NAMESPACE --ignore-not-found=true
  print_success "Namespace deleted"
  
  # Delete PersistentVolumes (if they still exist)
  kubectl delete pv --all --ignore-not-found=true
  print_success "PersistentVolumes cleaned up"
  
  print_success "All resources have been deleted!"
  
  echo -e "\n${GREEN}Cleanup complete.${NC}"
  echo -e "To verify: ${YELLOW}kubectl get namespaces | grep tutorial-app${NC}"
}

main
