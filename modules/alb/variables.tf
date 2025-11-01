###############################################################################
# Variables for ALB module
###############################################################################
variable "project" { type = string }
variable "vpc_id" { type = string }
variable "alb_sg_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "target_group_port" { type = number }
variable "health_check_path" { type = string }
variable "asg_name" { type = string }
variable "common_tags" { type = map(string) }
