resource "aws_ecr_repository" "this" {
  for_each = var.repositories

  name                 = each.value.name
  image_tag_mutability = var.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key         = var.encryption_kms_key
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-${each.value.name}"
  })
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = var.repositories

  repository = aws_ecr_repository.this[each.key].name
  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Expire untagged images older than configured age"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.lifecycle_policy_max_age
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Retain only the most recent tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["main", "release", "sha-", "v"]
          countType     = "imageCountMoreThan"
          countNumber   = var.lifecycle_policy_tagged_image_count
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
