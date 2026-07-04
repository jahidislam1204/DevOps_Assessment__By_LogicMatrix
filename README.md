# DevOps Assessment

This repository contains a small production-style note application and the infrastructure needed to run it on AWS EKS. It includes a Flask backend, static frontend, Kubernetes manifests, Terraform infrastructure, and a GitHub Actions deployment pipeline.

## Project Structure

- `backend/`: Flask API for note operations.
- `frontend/`: Static frontend served from a container.
- `k8s/`: Kubernetes manifests for namespace, deployments, services, ingress, autoscaling, disruption budgets, and network policy.
- `terraform/`: AWS infrastructure modules for VPC, EKS, node groups, ECR, RDS, IAM, CloudWatch, and platform add-ons.
- `.github/workflows/pipeline.yml`: CI/CD pipeline that builds Docker images, pushes them to Amazon ECR, and deploys to EKS.
- `docs/`: Operational documentation and improvement proposals.

## Application Flow

1. User accesses the frontend through the Kubernetes Ingress.
2. Frontend sends API requests to the backend service.
3. Backend handles note operations and connects to the configured database.
4. Kubernetes manages rollout, health checks, scaling, and service discovery.

## CI/CD Pipeline

The pipeline is intentionally simple and demo-friendly:

1. Checkout source code.
2. Authenticate to AWS using GitHub Actions secrets.
3. Login to Amazon ECR.
4. Build and push backend and frontend Docker images.
5. Configure `kubectl` for the EKS cluster.
6. Apply Kubernetes manifests.
7. Update Kubernetes deployment images.
8. Verify rollout status.

Required GitHub secrets:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

Common configurable GitHub repository variables:

- `AWS_REGION`
- `BACKEND_ECR_REPOSITORY`
- `FRONTEND_ECR_REPOSITORY`
- `EKS_CLUSTER_NAME`
- `K8S_NAMESPACE`

## Kubernetes

The Kubernetes layer includes:

- Namespace and service account.
- Backend and frontend deployments.
- ClusterIP services.
- Ingress for external access.
- Horizontal Pod Autoscalers.
- PodDisruptionBudgets.
- Network policy.
- ConfigMap and example Secret manifest.

## Terraform

The Terraform code provisions AWS infrastructure in a modular way:

- VPC and networking.
- EKS cluster and node group.
- ECR repositories.
- RDS database.
- IAM roles and policies.
- Security groups.
- CloudWatch resources.
- EKS platform add-ons.

See [terraform/README.md](terraform/README.md) for infrastructure-specific notes.

## Documentation

- [Troubleshooting Guide](docs/troubleshooting.md): Short answers for common production issues such as CrashLoopBackOff, ingress errors, database timeouts, DNS problems, and secret leaks.
- [Future Improvement Proposal](docs/future-improvements.md): Practical improvements for security, reliability, deployment safety, monitoring, cost, and disaster recovery.

## Useful Commands

```bash
kubectl get pods -n note-app
kubectl get services -n note-app
kubectl get ingress -n note-app
kubectl rollout status deployment/backend -n note-app
kubectl rollout status deployment/frontend -n note-app
```

## Notes

This project is built for assessment and demonstration purposes, but the structure follows real production concerns: repeatable infrastructure, containerized workloads, Kubernetes deployment, and operational documentation.
