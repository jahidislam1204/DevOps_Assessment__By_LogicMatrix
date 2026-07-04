variable "cluster_name" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "endpoint_private_access" {
  type = bool
}

variable "endpoint_public_access" {
  type = bool
}

variable "endpoint_public_access_cidrs" {
  type = list(string)
}

variable "enabled_cluster_log_types" {
  type = list(string)
}

variable "cloudwatch_log_group_retention" {
  type = number
}

variable "depends_on_log_group_names" {
  type = map(string)
}

variable "cluster_addons" {
  type = map(object({
    addon_version               = optional(string)
    configuration_values        = optional(string)
    service_account_role_arn    = optional(string)
    resolve_conflicts_on_create = optional(string, "OVERWRITE")
    resolve_conflicts_on_update = optional(string, "OVERWRITE")
  }))
  default = {}
}

variable "tags" {
  type = map(string)
}
