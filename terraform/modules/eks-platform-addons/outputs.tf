output "aws_load_balancer_controller_role_arn" {
  value = aws_iam_role.aws_load_balancer_controller.arn
}

output "aws_load_balancer_controller_release_name" {
  value = helm_release.aws_load_balancer_controller.name
}

output "metrics_server_release_name" {
  value = try(helm_release.metrics_server[0].name, null)
}
