resource "aws_cloudwatch_log_group" "this" {
  for_each = var.log_group_names

  name              = each.value
  retention_in_days = var.retention_in_days

  tags = merge(var.tags, {
    Name = each.value
  })
}

# EKS addon for Container Insights enhanced observability.
resource "aws_eks_addon" "container_insights" {
  count = var.create_container_insights_addon ? 1 : 0

  cluster_name                = var.cluster_name
  addon_name                  = "amazon-cloudwatch-observability"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-amazon-cloudwatch-observability"
  })

  depends_on = [aws_cloudwatch_log_group.this]
}
