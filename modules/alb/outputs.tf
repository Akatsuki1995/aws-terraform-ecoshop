# ─────────────────────────────────────────────────────────────────────────────
# OUTPUTS (optional, for debugging / reporting)
# ─────────────────────────────────────────────────────────────────────────────
output "alb_dns_name" {
  description = "Public DNS name of the ALB"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the Application Target Group"
  value       = aws_lb_target_group.app_tg.arn
}
