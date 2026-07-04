locals {
  az_map = {
    for index, az in var.availability_zones :
    az => {
      public_subnet_cidr      = var.public_subnet_cidrs[index]
      private_app_subnet_cidr = var.private_app_subnet_cidrs[index]
      private_db_subnet_cidr  = var.private_db_subnet_cidrs[index]
    }
  }
}

# Core network boundary for the application platform.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc"
  })
}

# Internet Gateway is required for public ALB connectivity and NAT egress.
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-igw"
  })
}

# Public subnets host ALBs and NAT gateways.
resource "aws_subnet" "public" {
  for_each = local.az_map

  vpc_id                  = aws_vpc.this.id
  availability_zone       = each.key
  cidr_block              = each.value.public_subnet_cidr
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                                        = "${var.name_prefix}-public-${each.key}"
    Tier                                        = "public"
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# Private application subnets host EKS worker nodes and application workloads.
resource "aws_subnet" "private_app" {
  for_each = local.az_map

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value.private_app_subnet_cidr

  tags = merge(var.tags, {
    Name                                        = "${var.name_prefix}-private-app-${each.key}"
    Tier                                        = "private-app"
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# Private database subnets isolate stateful data services from app tiers.
resource "aws_subnet" "private_db" {
  for_each = local.az_map

  vpc_id            = aws_vpc.this.id
  availability_zone = each.key
  cidr_block        = each.value.private_db_subnet_cidr

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-db-${each.key}"
    Tier = "private-db"
  })
}

# One Elastic IP per NAT Gateway supports highly available private egress.
resource "aws_eip" "nat" {
  for_each = aws_subnet.public

  domain = "vpc"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-eip-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

# NAT Gateway per AZ avoids cross-AZ dependency for private egress traffic.
resource "aws_nat_gateway" "this" {
  for_each = aws_subnet.public

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = each.value.id

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-nat-${each.key}"
  })

  depends_on = [aws_internet_gateway.this]
}

# Shared public route table for internet-facing resources.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-public-rt"
  })
}

# Private application route table per AZ routes egress through local NAT.
resource "aws_route_table" "private_app" {
  for_each = aws_nat_gateway.this

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-app-rt-${each.key}"
  })
}

# Private database route tables provide controlled outbound access if needed for
# package mirrors, patching, or agent traffic while keeping the DB private.
resource "aws_route_table" "private_db" {
  for_each = aws_nat_gateway.this

  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-private-db-rt-${each.key}"
  })
}

resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_app" {
  for_each = aws_subnet.private_app

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_app[each.key].id
}

resource "aws_route_table_association" "private_db" {
  for_each = aws_subnet.private_db

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_db[each.key].id
}
