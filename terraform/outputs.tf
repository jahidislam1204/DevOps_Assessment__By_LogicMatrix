output "cluster_name" {
  description = "Amazon EKS cluster name."
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Amazon EKS API server endpoint."
  value       = module.eks.cluster_endpoint
}

output "aws_load_balancer_controller_role_arn" {
  description = "IRSA role ARN used by the AWS Load Balancer Controller."
  value       = module.eks_platform_addons.aws_load_balancer_controller_role_arn
}

output "oidc_arn" {
  description = "IAM OIDC provider ARN for IRSA."
  value       = module.iam_oidc.oidc_provider_arn
}

output "vpc_id" {
  description = "VPC identifier."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet identifiers."
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Private application subnet identifiers."
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "Private database subnet identifiers."
  value       = module.vpc.private_db_subnet_ids
}

output "node_group_name" {
  description = "Managed node group name."
  value       = module.node_group.node_group_name
}

output "ecr_repository_urls" {
  description = "Map of ECR repository URLs."
  value       = module.ecr.repository_urls
}

output "rds_endpoint" {
  description = "Private RDS endpoint."
  value       = module.rds.db_endpoint
}

output "cloudwatch_log_groups" {
  description = "CloudWatch log groups created for the platform."
  value       = module.cloudwatch_logs.log_group_names
}

output "security_group_ids" {
  description = "Security groups created for the platform tiers."
  value = {
    alb       = module.security_groups.alb_security_group_id
    frontend  = module.security_groups.frontend_security_group_id
    backend   = module.security_groups.backend_security_group_id
    eks_nodes = module.security_groups.eks_nodes_security_group_id
    rds       = module.security_groups.rds_security_group_id
  }
}
