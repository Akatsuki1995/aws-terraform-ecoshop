###############################################################################
# RDS PostgreSQL Single-AZ (private)
# - DB Subnet Group uses private DB subnets
# - Multi-AZ disabled for sandbox permissions
# - Private only (no public access)
###############################################################################

resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-db-subnet-group"
  subnet_ids = var.db_subnet_ids
  tags       = merge(var.common_tags, { Name = "${var.project}-db-subnet-group" })
}

resource "aws_db_instance" "this" {
  identifier     = "${var.project}-postgres"
  engine         = "postgres"
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage     = 20
  storage_type          = "gp2"
  max_allocated_storage = 25

  multi_az               = var.multi_az # false in sandbox
  publicly_accessible    = false        # private DB
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.sg_db_id]

  username = var.db_username
  password = var.db_password

  backup_retention_period = 1 # minimal backup in sandbox
  deletion_protection     = false
  skip_final_snapshot     = true  # avoid snapshot requirement
  storage_encrypted       = false # simplify for sandbox

  tags = merge(var.common_tags, { Name = "${var.project}-rds-postgres" })
}
