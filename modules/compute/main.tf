###############################################################################
# Compute module:
# - Bastion EC2 in public subnet
# - App Launch Template + AutoScaling Group in private subnets
###############################################################################

# Use latest Amazon Linux 2 AMI (Kernel 5.10, gp2)
data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

# Bastion host (public subnet[0])
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.amazon_linux2.id
  instance_type               = "t3.micro"
  subnet_id                   = element(var.public_subnet_ids, 0)
  key_name                    = var.key_name
  vpc_security_group_ids      = [var.bastion_sg_id]
  associate_public_ip_address = true

  tags = merge(var.common_tags, { Name = "${var.project}-bastion" })
}

# User data for app instances (read file and base64 encode)
locals {
  user_data = file(var.user_data_path)
}

# Launch Template for app instances (private subnets)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "${var.project}-app-"
  image_id      = data.aws_ami.amazon_linux2.id
  instance_type = "t3.small"
  key_name      = var.key_name

  vpc_security_group_ids = [var.app_sg_id]
  user_data              = base64encode(local.user_data)

  # Tag instances at launch
  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.common_tags, { Name = "${var.project}-app" })
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Auto Scaling Group: min=2 (HA), spans both private subnets
resource "aws_autoscaling_group" "app_asg" {
  name                      = "${var.project}-asg"
  min_size                  = var.app_min_size
  max_size                  = var.app_max_size
  desired_capacity          = var.app_desired_capacity
  vpc_zone_identifier       = var.private_app_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 60

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  # Propagate Name tag
  tag {
    key                 = "Name"
    value               = "${var.project}-app"
    propagate_at_launch = true
  }
}
# Data source to fetch private IPs of instances in the Auto Scaling Group
data "aws_instances" "app" {
  instance_tags = {
    Project = var.project
  }
  filter {
    name   = "tag:Name"
    values = ["ecoshop-app"]
  }
}
