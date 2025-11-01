###############################################################################
# Handy outputs for testing and screenshots
###############################################################################

output "alb_dns_name" {
  description = "Public ALB DNS name (access the app here)"
  value       = module.alb.alb_dns_name
}

output "bastion_public_ip" {
  description = "Bastion public IP for SSH (from your IP only)"
  value       = module.compute.bastion_public_ip
}

output "rds_endpoint" {
  description = "Private PostgreSQL RDS endpoint"
  value       = module.rds.rds_endpoint
}
output "app_private_ips" {
  value       = module.compute.app_private_ips
  description = "Private IPs of private app EC2 instances"
}
