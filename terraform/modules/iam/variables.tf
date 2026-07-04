variable "name_prefix" {
  type = string
}

variable "create_cluster_role" {
  type    = bool
  default = true
}

variable "create_node_role" {
  type    = bool
  default = true
}

variable "create_oidc_provider" {
  type    = bool
  default = false
}

variable "cluster_oidc_issuer" {
  type    = string
  default = null

  validation {
    condition     = var.create_oidc_provider ? var.cluster_oidc_issuer != null : true
    error_message = "cluster_oidc_issuer must be provided when create_oidc_provider is true."
  }
}

variable "tags" {
  type = map(string)
}
