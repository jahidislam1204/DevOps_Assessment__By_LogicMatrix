locals {
  name_prefix = "${var.environment}-${var.cluster_name}"

  common_tags = merge(
    {
      Environment = var.environment
      Project     = "note-app"
      ManagedBy   = "Terraform"
      Repository  = "DevOps_Assessment__By_LogicMatrix"
    },
    var.tags
  )

  ecr_repositories = {
    backend = {
      name = "note-backend"
    }
    frontend = {
      name = "note-frontend"
    }
  }

  cloudwatch_log_groups = {
    application = "/aws/note-app/${var.environment}/application"
    eks         = "/aws/eks/${var.cluster_name}/cluster"
  }
}
