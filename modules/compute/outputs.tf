###############################################################################
# Export bastion IP and ASG name (used by ALB module)
###############################################################################
output "bastion_public_ip" {
  value       = aws_instance.bastion.public_ip
  description = "Public IP of the bastion host"
}

output "app_asg_name" {
  value       = aws_autoscaling_group.app_asg.name
  description = "Name of the App AutoScaling Group"
}
output "app_private_ips" {
  description = "Private IPs of app instances"
  value       = data.aws_instances.app.private_ips
}
