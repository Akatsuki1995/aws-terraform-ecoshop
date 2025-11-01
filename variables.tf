###############################################################################
# Root-level variables shared by modules (wired in main.tf)
###############################################################################

# Region (we'll use us-east-1 for sandbox)
variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

# Project name for tagging/prefixes
variable "project" {
  description = "Project name prefix used in tags and resource names"
  type        = string
  default     = "ecoshop"
}

# VPC CIDR for the whole environment
variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnet CIDRs per tier
variable "public_subnets" {
  description = "Public subnets (for ALB and Bastion)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_app_subnets" {
  description = "Private subnets for application servers / ASG"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "private_db_subnets" {
  description = "Private subnets for database"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.200.0/24"]
}

# Availability Zones (letters vary per account; override in tfvars if needed)
variable "azs" {
  description = "List of two Availability Zones to spread subnets across"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Lock down SSH to your public IP only
variable "allowed_ssh_cidr" {
  description = "Admin IP/CIDR allowed to SSH to Bastion (e.g., 1.2.3.4/32)"
  type        = string
  default     = "0.0.0.0/0" # replace in tfvars!
}

# Existing EC2 keypair name to log into instances (provided by your instructor)
variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

# Database credentials (PostgreSQL)
variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
  default     = "postgres"
}

variable "db_password" {
  description = "PostgreSQL master password"
  type        = string
  sensitive   = true
}

# App autoscaling sizes (HA with min 2 instances as required)
variable "app_min_size" {
  description = "ASG minimum size"
  type        = number
  default     = 2
}

variable "app_max_size" {
  description = "ASG maximum size"
  type        = number
  default     = 4
}

variable "app_desired_capacity" {
  description = "ASG desired capacity"
  type        = number
  default     = 2
}
