variable "cluster_name" {
  type = string
}

variable "node_group_name" {
  type = string
}

variable "node_role_arn" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "instance_types" {
  type = list(string)
}

variable "ami_type" {
  type = string
}

variable "desired_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "update_max_unavailable_percentage" {
  type = number
}

variable "capacity_type" {
  type = string
}

variable "source_security_group_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}
