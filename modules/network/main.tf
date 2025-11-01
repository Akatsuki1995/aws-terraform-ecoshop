###############################################################################
# Network module:
# - VPC with DNS support
# - 2 public subnets (web/bastion/ALB), 2 private app, 2 private db (across AZs)
# - IGW, single NAT (cost-aware), route tables and associations
###############################################################################

# VPC with DNS enabled
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.common_tags, { Name = "${var.project}-vpc" })
}

# Internet Gateway for outbound/inbound internet to public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.project}-igw" })
}

# Public subnets (map_public_ip_on_launch = true for ALB/Bastion)
resource "aws_subnet" "public" {
  for_each                = { for idx, cidr in var.public_subnets : idx => { cidr = cidr, az = var.azs[idx] } }
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, {
    Name = "${var.project}-public-${each.value.az}"
    Tier = "web"
  })
}

# Elastic IP for NAT (single-NAT pattern for lab/cost)
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(var.common_tags, { Name = "${var.project}-nat-eip" })
}

# NAT Gateway in first public subnet (all private subnets egress through here)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id
  tags          = merge(var.common_tags, { Name = "${var.project}-nat" })
  depends_on    = [aws_internet_gateway.igw]
}

# Private APP subnets (no public IP)
resource "aws_subnet" "private_app" {
  for_each          = { for idx, cidr in var.private_app_subnets : idx => { cidr = cidr, az = var.azs[idx] } }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(var.common_tags, {
    Name = "${var.project}-app-${each.value.az}"
    Tier = "app"
  })
}

# Private DB subnets (no public IP)
resource "aws_subnet" "private_db" {
  for_each          = { for idx, cidr in var.private_db_subnets : idx => { cidr = cidr, az = var.azs[idx] } }
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = merge(var.common_tags, {
    Name = "${var.project}-db-${each.value.az}"
    Tier = "db"
  })
}

# Route table for public subnets (0.0.0.0/0 -> IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.project}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Route table for private subnets (0.0.0.0/0 -> NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  tags   = merge(var.common_tags, { Name = "${var.project}-private-rt" })
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private route table to both app and db subnets
resource "aws_route_table_association" "private_app_assoc" {
  for_each       = aws_subnet.private_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_db_assoc" {
  for_each       = aws_subnet.private_db
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private.id
}
