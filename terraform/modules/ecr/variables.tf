variable "name_prefix" {
  type = string
}

variable "repositories" {
  type = map(object({
    name = string
  }))
}

variable "image_tag_mutability" {
  type = string
}

variable "scan_on_push" {
  type = bool
}

variable "encryption_type" {
  type = string
}

variable "encryption_kms_key" {
  type    = string
  default = null
}

variable "lifecycle_policy_max_age" {
  type = number
}

variable "lifecycle_policy_tagged_image_count" {
  type = number
}

variable "tags" {
  type = map(string)
}
