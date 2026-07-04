output "eks_cluster_role_arn" {
  value = var.create_cluster_role ? aws_iam_role.eks_cluster[0].arn : null
}

output "eks_node_role_arn" {
  value = var.create_node_role ? aws_iam_role.eks_node[0].arn : null
}

output "oidc_provider_arn" {
  value = var.create_oidc_provider ? aws_iam_openid_connect_provider.this[0].arn : null
}
