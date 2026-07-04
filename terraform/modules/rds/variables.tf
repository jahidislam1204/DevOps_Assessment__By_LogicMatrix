variable "name_prefix" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_instance_class" {
  type = string
}

variable "db_port" {
  type = number
}

variable "allocated_storage" {
  type = number
}

variable "max_allocated_storage" {
  type = number
}

variable "backup_retention_period" {
  type = number
}

variable "backup_window" {
  type = string
}

variable "maintenance_window" {
  type = string
}

variable "monitoring_interval" {
  type = number
}

variable "subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "multi_az" {
  type = bool
}

variable "deletion_protection" {
  type = bool
}

variable "storage_encrypted" {
  type = bool
}

variable "publicly_accessible" {
  type = bool
}

variable "engine_version" {
  type = string
}

variable "enabled_cloudwatch_logs_exports" {
  type = list(string)
}

variable "db_parameters" {
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "character_set_server"
      value = "utf8mb4"
    },
    {
      name  = "slow_query_log"
      value = "1"
    }
  ]
}

variable "tags" {
  type = map(string)
}
