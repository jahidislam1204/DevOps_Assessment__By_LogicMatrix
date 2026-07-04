variable "cluster_name" {
  type = string
}

variable "oidc_provider_arn" {
  type = string
}

variable "oidc_issuer_url" {
  type = string
}

variable "region" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "aws_load_balancer_controller_chart_version" {
  type    = string
  default = "1.14.0"
}

variable "metrics_server_chart_version" {
  type    = string
  default = "3.12.2"
}

variable "install_metrics_server" {
  description = "Install Metrics Server with Helm. Set to false when the cluster already has Metrics Server installed."
  type        = bool
  default     = false
}

variable "tags" {
  type = map(string)
}
