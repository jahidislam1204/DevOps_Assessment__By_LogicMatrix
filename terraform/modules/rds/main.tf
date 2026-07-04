# Enhanced monitoring role streams instance-level metrics to CloudWatch.
data "aws_iam_policy_document" "enhanced_monitoring_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  name               = "${var.name_prefix}-rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring_assume_role.json

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-monitoring-role"
  })
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  role       = aws_iam_role.enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

# Dedicated DB subnet group ensures the database stays in isolated private subnets.
resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-db-subnet-group"
  })
}

# Parameter group captures MySQL defaults that are commonly tuned in production.
resource "aws_db_parameter_group" "this" {
  name        = "${var.name_prefix}-mysql-parameter-group"
  family      = "mysql8.0"
  description = "Parameter group for the note application MySQL database"

  dynamic "parameter" {
    for_each = var.db_parameters

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-mysql-parameter-group"
  })
}

resource "aws_db_instance" "this" {
  identifier                      = "${var.name_prefix}-mysql"
  engine                          = "mysql"
  engine_version                  = var.engine_version
  instance_class                  = var.db_instance_class
  port                            = var.db_port
  allocated_storage               = var.allocated_storage
  max_allocated_storage           = var.max_allocated_storage
  storage_type                    = "gp3"
  storage_encrypted               = var.storage_encrypted
  db_name                         = var.db_name
  username                        = var.db_username
  password                        = var.db_password
  db_subnet_group_name            = aws_db_subnet_group.this.name
  vpc_security_group_ids          = var.security_group_ids
  multi_az                        = var.multi_az
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  maintenance_window              = var.maintenance_window
  deletion_protection             = var.deletion_protection
  publicly_accessible             = var.publicly_accessible
  skip_final_snapshot             = false
  final_snapshot_identifier       = "${var.name_prefix}-mysql-final"
  apply_immediately               = false
  auto_minor_version_upgrade      = true
  performance_insights_enabled    = true
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = aws_iam_role.enhanced_monitoring.arn
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  delete_automated_backups        = false
  copy_tags_to_snapshot           = true
  parameter_group_name            = aws_db_parameter_group.this.name

  timeouts {
    create = "90m"
    update = "90m"
    delete = "90m"
  }

  lifecycle {
    precondition {
      condition     = var.publicly_accessible == false
      error_message = "RDS must remain private for this assessment."
    }

    precondition {
      condition     = length(var.subnet_ids) >= 2
      error_message = "RDS requires at least two private database subnets for Multi-AZ deployment."
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-mysql"
  })

  depends_on = [aws_iam_role_policy_attachment.enhanced_monitoring]
}
