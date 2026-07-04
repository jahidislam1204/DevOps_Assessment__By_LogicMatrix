variable "environment" {
  description = "Deployment environment name used in naming and tagging."
  type        = string
  default     = "prod"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.environment))
    error_message = "environment must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "AWS region for all infrastructure resources."
  type        = string
  default     = "ap-southeast-2"

  validation {
    condition     = var.region == "ap-southeast-2"
    error_message = "This assessment is scoped to the ap-southeast-2 region."
  }
}

variable "cluster_name" {
  description = "Logical name for the EKS cluster."
  type        = string
  default     = "note-app-eks"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.cluster_name))
    error_message = "cluster_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "kubernetes_version" {
  description = "Amazon EKS Kubernetes control plane version."
  type        = string
  default     = "1.31"

  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.kubernetes_version))
    error_message = "kubernetes_version must follow the EKS major.minor format, for example 1.31."
  }
}

variable "cluster_endpoint_public_access" {
  description = "Whether the EKS API endpoint is reachable from the public internet."
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "Allowed CIDR blocks for the public EKS API endpoint when public access is enabled."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_endpoint_private_access" {
  description = "Whether the EKS API endpoint is reachable from inside the VPC."
  type        = bool
  default     = true
}

variable "vpc_cidr" {
  description = "CIDR block for the application VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "availability_zones" {
  description = "Availability Zones used for Multi-AZ deployment."
  type        = list(string)
  default     = ["ap-southeast-2a", "ap-southeast-2b"]

  validation {
    condition     = length(var.availability_zones) == 2
    error_message = "Exactly two Availability Zones are required for this assessment."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets used by internet-facing load balancers and NAT."
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs are required."
  }
}

variable "private_app_subnet_cidrs" {
  description = "CIDRs for private application subnets used by EKS worker nodes and pods."
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.11.0/24"]

  validation {
    condition     = length(var.private_app_subnet_cidrs) == 2
    error_message = "Exactly two private application subnet CIDRs are required."
  }
}

variable "private_db_subnet_cidrs" {
  description = "CIDRs for private database subnets used by Amazon RDS."
  type        = list(string)
  default     = ["10.0.20.0/24", "10.0.21.0/24"]

  validation {
    condition     = length(var.private_db_subnet_cidrs) == 2
    error_message = "Exactly two private database subnet CIDRs are required."
  }
}

variable "node_instance_types" {
  description = "Managed node group EC2 instance types."
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_desired_size" {
  description = "Desired number of worker nodes."
  type        = number
  default     = 2

  validation {
    condition     = var.node_desired_size >= 2
    error_message = "node_desired_size must be at least 2 for production-style HA."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes."
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of worker nodes."
  type        = number
  default     = 4
}

variable "node_disk_size" {
  description = "Root volume size in GiB for worker nodes."
  type        = number
  default     = 50
}

variable "node_ami_type" {
  description = "AMI type for the managed node group."
  type        = string
  default     = "AL2023_x86_64_STANDARD"
}

variable "node_update_max_unavailable_percentage" {
  description = "Percentage of nodes that may be unavailable during a rolling node group update."
  type        = number
  default     = 25
}

variable "db_name" {
  description = "Name of the MySQL database to create."
  type        = string
  default     = "noteapp"

  validation {
    condition     = can(regex("^[A-Za-z][A-Za-z0-9_]*$", var.db_name))
    error_message = "db_name must start with a letter and contain only letters, numbers, and underscores."
  }
}

variable "db_username" {
  description = "Master username for the MySQL instance."
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Master password for the MySQL instance."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.db_password) >= 16
    error_message = "db_password must be at least 16 characters long."
  }
}

variable "db_allocated_storage" {
  description = "Initial storage allocation for the MySQL instance in GiB."
  type        = number
  default     = 100
}

variable "db_max_allocated_storage" {
  description = "Maximum autoscaled storage allocation for the MySQL instance in GiB."
  type        = number
  default     = 200
}

variable "db_instance_class" {
  description = "RDS DB instance class."
  type        = string
  default     = "db.t3.medium"
}

variable "db_port" {
  description = "Database listener port."
  type        = number
  default     = 3306
}

variable "db_backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "db_backup_window" {
  description = "Preferred daily backup window in UTC."
  type        = string
  default     = "16:00-17:00"
}

variable "db_maintenance_window" {
  description = "Preferred weekly maintenance window in UTC."
  type        = string
  default     = "sun:18:00-sun:19:00"
}

variable "db_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds."
  type        = number
  default     = 60
}

variable "db_enabled_cloudwatch_logs_exports" {
  description = "Database log types to export to CloudWatch Logs."
  type        = list(string)
  default     = ["error", "general", "slowquery"]
}

variable "cloudwatch_log_retention_days" {
  description = "Retention period in days for CloudWatch log groups."
  type        = number
  default     = 30
}

variable "ecr_lifecycle_tagged_image_count" {
  description = "How many tagged images to retain in each ECR repository."
  type        = number
  default     = 30
}

variable "ecr_kms_key_arn" {
  description = "Optional KMS key ARN used for ECR repository encryption."
  type        = string
  default     = null
}

variable "tags" {
  description = "Additional tags applied to all resources."
  type        = map(string)
  default     = {}
}
