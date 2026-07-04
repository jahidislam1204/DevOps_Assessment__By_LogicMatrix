variable "name_prefix" {
  type = string
}

variable "retention_in_days" {
  type = number
}

variable "log_group_names" {
  type = map(string)
}

variable "enable_eks_logs" {
  type = bool
}

variable "create_container_insights_addon" {
  type = bool
}

variable "cluster_name" {
  type    = string
  default = null

  validation {
    condition     = var.create_container_insights_addon ? var.cluster_name != null : true
    error_message = "cluster_name must be provided when create_container_insights_addon is true."
  }
}

variable "tags" {
  type = map(string)
}
