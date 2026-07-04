resource "aws_eks_node_group" "this" {
  cluster_name         = var.cluster_name
  node_group_name      = var.node_group_name
  node_role_arn        = var.node_role_arn
  subnet_ids           = var.subnet_ids
  capacity_type        = var.capacity_type
  instance_types       = var.instance_types
  ami_type             = var.ami_type
  force_update_version = true

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  update_config {
    max_unavailable_percentage = var.update_max_unavailable_percentage
  }

  launch_template {
    id      = aws_launch_template.this.id
    version = aws_launch_template.this.latest_version
  }

  timeouts {
    create = "45m"
    update = "60m"
    delete = "45m"
  }

  lifecycle {
    ignore_changes = [
      scaling_config[0].desired_size
    ]

    precondition {
      condition     = var.max_size >= var.desired_size && var.desired_size >= var.min_size
      error_message = "Node group scaling values must satisfy min <= desired <= max."
    }
  }

  tags = merge(var.tags, {
    Name                                            = var.node_group_name
    "k8s.io/cluster-autoscaler/enabled"             = "true"
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  })
}

# Launch template allows future extension for EBS tuning, IMDSv2 enforcement,
# and bootstrap customization without replacing the module structure.
resource "aws_launch_template" "this" {
  name_prefix = "${var.node_group_name}-"

  vpc_security_group_ids = var.source_security_group_ids

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp3"
      encrypted             = true
      delete_on_termination = true
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(var.tags, {
      Name = var.node_group_name
    })
  }

  tag_specifications {
    resource_type = "volume"

    tags = merge(var.tags, {
      Name = "${var.node_group_name}-volume"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}
