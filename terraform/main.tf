# Core networking layer used by every downstream service.
module "vpc" {
  source = "./modules/vpc"

  name_prefix              = local.name_prefix
  vpc_cidr                 = var.vpc_cidr
  availability_zones       = var.availability_zones
  public_subnet_cidrs      = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs  = var.private_db_subnet_cidrs
  cluster_name             = var.cluster_name
  tags                     = local.common_tags
}

# Identity layer for EKS control plane and worker nodes.
module "iam_roles" {
  source = "./modules/iam"

  name_prefix          = local.name_prefix
  create_cluster_role  = true
  create_node_role     = true
  create_oidc_provider = false
  tags                 = local.common_tags
}

# Security groups are separated by tier to keep traffic boundaries explicit.
module "security_groups" {
  source = "./modules/security-groups"

  name_prefix  = local.name_prefix
  cluster_name = var.cluster_name
  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  tags         = local.common_tags
}

# CloudWatch log groups are created first so dependent services can publish to them.
module "cloudwatch_logs" {
  source = "./modules/cloudwatch"

  name_prefix                     = local.name_prefix
  retention_in_days               = var.cloudwatch_log_retention_days
  log_group_names                 = local.cloudwatch_log_groups
  enable_eks_logs                 = true
  create_container_insights_addon = false
  cluster_name                    = null
  tags                            = local.common_tags
}

# EKS control plane deployed into private application subnets.
module "eks" {
  source = "./modules/eks"

  cluster_name                   = var.cluster_name
  kubernetes_version             = var.kubernetes_version
  cluster_role_arn               = module.iam_roles.eks_cluster_role_arn
  subnet_ids                     = module.vpc.private_app_subnet_ids
  security_group_ids             = [module.security_groups.eks_cluster_security_group_id]
  endpoint_private_access        = var.cluster_endpoint_private_access
  endpoint_public_access         = var.cluster_endpoint_public_access
  endpoint_public_access_cidrs   = var.cluster_endpoint_public_access_cidrs
  enabled_cluster_log_types      = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention = var.cloudwatch_log_retention_days
  depends_on_log_group_names     = module.cloudwatch_logs.log_group_names
  cluster_addons = {
    kube-proxy = {}
    vpc-cni = {
      configuration_values = jsonencode({
        enableNetworkPolicy = "true"
        nodeAgent = {
          healthProbeBindAddr = "8163"
          metricsBindAddr     = "8162"
        }
        env = {
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
    eks-pod-identity-agent = {}
  }
  tags = local.common_tags

  depends_on = [module.cloudwatch_logs]
}

# Managed node group kept separate for scaling and lifecycle control.
module "node_group" {
  source = "./modules/node-group"

  cluster_name                      = module.eks.cluster_name
  node_group_name                   = "${local.name_prefix}-system"
  node_role_arn                     = module.iam_roles.eks_node_role_arn
  subnet_ids                        = module.vpc.private_app_subnet_ids
  instance_types                    = var.node_instance_types
  ami_type                          = var.node_ami_type
  desired_size                      = var.node_desired_size
  min_size                          = var.node_min_size
  max_size                          = var.node_max_size
  disk_size                         = var.node_disk_size
  update_max_unavailable_percentage = var.node_update_max_unavailable_percentage
  capacity_type                     = "ON_DEMAND"
  source_security_group_ids         = [module.security_groups.eks_nodes_security_group_id]
  tags                              = local.common_tags

  depends_on = [module.eks]
}

# CoreDNS needs schedulable worker nodes before it can become healthy.
resource "aws_eks_addon" "coredns" {
  cluster_name                = module.eks.cluster_name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(local.common_tags, {
    Name = "${var.cluster_name}-coredns"
  })

  depends_on = [module.node_group]
}

# OIDC provider is created after the cluster exists so IRSA can be enabled.
module "iam_oidc" {
  source = "./modules/iam"

  name_prefix          = local.name_prefix
  create_cluster_role  = false
  create_node_role     = false
  create_oidc_provider = true
  cluster_oidc_issuer  = module.eks.oidc_issuer_url
  tags                 = local.common_tags

  depends_on = [module.eks]
}

# Cluster observability addon is installed only after the control plane exists.
module "cloudwatch_addon" {
  source = "./modules/cloudwatch"

  name_prefix                     = local.name_prefix
  retention_in_days               = var.cloudwatch_log_retention_days
  log_group_names                 = {}
  enable_eks_logs                 = true
  create_container_insights_addon = true
  cluster_name                    = module.eks.cluster_name
  tags                            = local.common_tags

  depends_on = [module.eks]
}

# Kubernetes platform add-ons required before application manifests are applied.
module "eks_platform_addons" {
  source = "./modules/eks-platform-addons"

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.iam_oidc.oidc_provider_arn
  oidc_issuer_url   = module.eks.oidc_issuer_url
  region            = var.region
  vpc_id            = module.vpc.vpc_id
  tags              = local.common_tags

  depends_on = [
    module.iam_oidc,
    module.node_group,
    aws_eks_addon.coredns,
    module.cloudwatch_addon
  ]
}

# Private container registries for backend and frontend images.
module "ecr" {
  source = "./modules/ecr"

  name_prefix                         = local.name_prefix
  repositories                        = local.ecr_repositories
  image_tag_mutability                = "IMMUTABLE"
  scan_on_push                        = true
  encryption_type                     = var.ecr_kms_key_arn != null ? "KMS" : "AES256"
  encryption_kms_key                  = var.ecr_kms_key_arn
  lifecycle_policy_max_age            = 30
  lifecycle_policy_tagged_image_count = var.ecr_lifecycle_tagged_image_count
  tags                                = local.common_tags
}

# Private RDS MySQL instance placed in isolated database subnets.
module "rds" {
  source = "./modules/rds"

  name_prefix                     = local.name_prefix
  db_name                         = var.db_name
  db_username                     = var.db_username
  db_password                     = var.db_password
  db_instance_class               = var.db_instance_class
  db_port                         = var.db_port
  allocated_storage               = var.db_allocated_storage
  max_allocated_storage           = var.db_max_allocated_storage
  backup_retention_period         = var.db_backup_retention_period
  backup_window                   = var.db_backup_window
  maintenance_window              = var.db_maintenance_window
  monitoring_interval             = var.db_monitoring_interval
  enabled_cloudwatch_logs_exports = var.db_enabled_cloudwatch_logs_exports
  subnet_ids                      = module.vpc.private_db_subnet_ids
  vpc_id                          = module.vpc.vpc_id
  security_group_ids              = [module.security_groups.rds_security_group_id]
  multi_az                        = true
  deletion_protection             = true
  storage_encrypted               = true
  publicly_accessible             = false
  engine_version                  = "8.0"
  tags                            = local.common_tags
}
