# Terraform Infrastructure

Enterprise-style AWS infrastructure for the note application. This stack builds:

- Multi-AZ VPC with public, private application, and private database subnets
- Amazon EKS cluster and managed node group
- IAM roles and OIDC provider for IRSA
- Amazon ECR repositories for backend and frontend
- Private Amazon RDS MySQL
- CloudWatch log groups and EKS Container Insights support

## Usage

The default setup uses local Terraform state, so initialization works without a
pre-existing remote backend:

```bash
terraform init
terraform plan \
  -var="db_username=adminuser" \
  -var="db_password=replace-with-a-strong-password"
terraform apply \
  -var="db_username=adminuser" \
  -var="db_password=replace-with-a-strong-password"
```

To use remote S3 state, create the state bucket first, copy
`backend.s3.example.hcl` to a local backend config file, replace the bucket
name, and initialize with:

```bash
terraform init -backend-config=<your-backend-file>.hcl
```

The S3 backend example uses Terraform's native `use_lockfile` state locking
instead of the deprecated DynamoDB lock table argument.

## Notes

- The configuration uses only custom local modules.
- Private workloads run in private subnets behind NAT.
- RDS is private and not publicly accessible.
- EKS is configured to support IRSA and Cluster Autoscaler compatibility.
