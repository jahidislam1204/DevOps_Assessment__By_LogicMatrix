# KMS key encrypts Kubernetes secrets stored in the EKS control plane datastore.
resource "aws_kms_key" "eks" {
  description             = "KMS key for ${var.cluster_name} EKS secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-eks-kms"
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.cluster_name}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# EKS control plane definition.
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.endpoint_public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }

    resources = ["secrets"]
  }

  access_config {
    authentication_mode                         = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = true
  }

  timeouts {
    create = "30m"
    update = "60m"
    delete = "30m"
  }

  lifecycle {
    precondition {
      condition     = length(var.subnet_ids) >= 2
      error_message = "EKS requires at least two subnets across AZs."
    }

    precondition {
      condition     = var.endpoint_public_access ? length(var.endpoint_public_access_cidrs) > 0 : true
      error_message = "At least one public access CIDR must be supplied when endpoint_public_access is enabled."
    }
  }

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

# Core EKS managed addons improve day-2 operability and upgrade hygiene.
resource "aws_eks_addon" "this" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.this.name
  addon_name                  = each.key
  addon_version               = try(each.value.addon_version, null)
  configuration_values        = try(each.value.configuration_values, null)
  service_account_role_arn    = try(each.value.service_account_role_arn, null)
  resolve_conflicts_on_create = try(each.value.resolve_conflicts_on_create, "OVERWRITE")
  resolve_conflicts_on_update = try(each.value.resolve_conflicts_on_update, "OVERWRITE")

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}"
  })
}
