# Helm chart

Minimal Helm chart for the Spring Boot API.

## Install

```bash
cd spring-boot-react-mysql
helm lint ./helm/springboot-api
helm upgrade --install springboot-api ./helm/springboot-api \
  --namespace tutorial-app --create-namespace \
  --set image.repository=ahmedikram567/spring-boot-server \
  --set image.tag=latest \
  --set mysql.password=your_mysql_password
```

## Check it

```bash
kubectl get pods -n tutorial-app
kubectl get svc -n tutorial-app
kubectl port-forward svc/springboot-api 8080:8080 -n tutorial-app
```

Open:

```bash
http://localhost:8080/api/tutorials
```

## Upgrade

```bash
helm upgrade springboot-api ./helm/springboot-api -n tutorial-app \
  --set image.tag=new-tag
```