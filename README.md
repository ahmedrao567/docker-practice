# Docker Practice

## CI/CD

The Spring Boot + React + MySQL example includes a GitHub Actions workflow at [spring-boot-react-mysql/.github/workflows/ci-cd.yml](spring-boot-react-mysql/.github/workflows/ci-cd.yml).

It runs backend and frontend checks on every pull request and push, then publishes Docker images to GitHub Container Registry from `main`.
