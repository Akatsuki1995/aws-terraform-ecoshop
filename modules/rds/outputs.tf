###############################################################################
# Export DB endpoint for connectivity tests
###############################################################################
output "rds_endpoint" {
  value       = aws_db_instance.this.address
  description = "PostgreSQL endpoint (private)"
}
