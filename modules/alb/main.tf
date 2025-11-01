###############################################################################
# ALB MODULE — Application Load Balancer Layer
#
# PURPOSE:
#   - Creates an Internet-facing Application Load Balancer (ALB)
#   - Routes HTTP (port 80) traffic to private app instances (port 8080)
#   - Includes health checks on "/" to monitor backend availability
#   - Attaches the Auto Scaling Group (ASG) to the Target Group
#
# FLOW:
#   Internet (port 80)
#      ↓
#   ALB (security group: web)
#      ↓
#   Target Group → forwards to EC2 App Instances (port 8080)
#
# DEPENDS ON:
#   - VPC/Subnets from the network module
#   - ALB Security Group (web-sg)
#   - App ASG from the compute module
###############################################################################

# ─────────────────────────────────────────────────────────────────────────────
# ALB Resource: Internet-facing Application Load Balancer
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb" "this" {
  name               = "${var.project}-alb"  # Example: ecoshop-alb
  load_balancer_type = "application"         # HTTP(S) Load Balancer
  internal           = false                 # Internet-facing
  security_groups    = [var.alb_sg_id]       # Allow 80/443 inbound
  subnets            = var.public_subnet_ids # Must be public subnets
  idle_timeout       = 60                    # 60s connection timeout

  tags = merge(
    var.common_tags,
    { Name = "${var.project}-alb" }
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Target Group: routes ALB requests to EC2 instances on port 8080
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb_target_group" "app_tg" {
  name        = "${var.project}-tg" # Example: ecoshop-tg
  port        = 8080                # EC2 instance port (Apache)
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance" # Targets are EC2 instances

  # Health check configuration for backend instances
  health_check {
    enabled             = true
    path                = "/"            # Root path
    port                = "traffic-port" # Use target port (8080)
    protocol            = "HTTP"
    interval            = 15 # Every 15 seconds
    timeout             = 5  # 5s per check
    healthy_threshold   = 2  # 2 successes = healthy
    unhealthy_threshold = 2  # 2 failures = unhealthy
  }

  tags = merge(
    var.common_tags,
    { Name = "${var.project}-tg" }
  )
}

# ─────────────────────────────────────────────────────────────────────────────
# Listener: accepts HTTP requests on port 80 and forwards to Target Group
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80 # Public port (HTTP)
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn # Forward to app_tg (8080)
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# ASG Attachment: connects Auto Scaling Group instances to the Target Group
# ─────────────────────────────────────────────────────────────────────────────
resource "aws_autoscaling_attachment" "asg_to_tg" {
  autoscaling_group_name = var.asg_name # From compute module
  lb_target_group_arn    = aws_lb_target_group.app_tg.arn
}
