###############################################################################
# Security module:
# - Creates 4 Security Groups (web/alb, app, db, bastion)
# - Uses explicit rule resources for clarity and least privilege
###############################################################################

# ALB/Web SG: allows HTTP/HTTPS from the Internet
resource "aws_security_group" "web" {
  name        = "${var.project}-web-sg"
  description = "ALB ingress from Internet"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.project}-web-sg" })
}

# App SG: only receives 8080 from Web SG and SSH 22 from Bastion SG
resource "aws_security_group" "app" {
  name        = "${var.project}-app-sg"
  description = "Application tier"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.project}-app-sg" })
}

# DB SG: only receives 5432 (PostgreSQL) from App SG
resource "aws_security_group" "db" {
  name        = "${var.project}-db-sg"
  description = "Database tier"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.project}-db-sg" })
}

# Bastion SG: SSH allowed only from your IP
resource "aws_security_group" "bastion" {
  name        = "${var.project}-bastion-sg"
  description = "Admin bastion access"
  vpc_id      = var.vpc_id
  tags        = merge(var.common_tags, { Name = "${var.project}-bastion-sg" })
}

# --- Rules for SG-Web (ALB) --------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "web_egress_all" {
  security_group_id = aws_security_group.web.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# --- Rules for SG-Bastion ----------------------------------------------------
resource "aws_vpc_security_group_ingress_rule" "bastion_ssh" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = var.allowed_ssh_cidr
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "bastion_egress_all" {
  security_group_id = aws_security_group.bastion.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# --- Rules for SG-App --------------------------------------------------------
# Allow HTTP 8080 ONLY from SG-Web (ALB)
resource "aws_vpc_security_group_ingress_rule" "app_from_web_8080" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  ip_protocol                  = "tcp"
  from_port                    = 8080
  to_port                      = 8080
}
# Allow SSH 22 ONLY from SG-Bastion
resource "aws_vpc_security_group_ingress_rule" "app_from_bastion_22" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 22
  to_port                      = 22
}
# Allow egress to anywhere (for updates via NAT)
resource "aws_vpc_security_group_egress_rule" "app_egress_all" {
  security_group_id = aws_security_group.app.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# --- Rules for SG-DB ---------------------------------------------------------
# Allow PostgreSQL 5432 ONLY from SG-App
resource "aws_vpc_security_group_ingress_rule" "db_from_app_5432" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}
# Egress open (for patches/monitoring inside VPC)
resource "aws_vpc_security_group_egress_rule" "db_egress_all" {
  security_group_id = aws_security_group.db.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
# Allow PostgreSQL 5432 ONLY from SG-Bastion (for admin access)
resource "aws_vpc_security_group_ingress_rule" "db_from_bastion_5432" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.bastion.id
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}