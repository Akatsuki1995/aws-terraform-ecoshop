###############################################################################
# Variables for RDS module (PostgreSQL, Single-AZ)
###############################################################################
variable "project" { type = string }
variable "vpc_id" { type = string }
variable "db_subnet_ids" { type = list(string) }
variable "sg_db_id" { type = string }
variable "db_username" { type = string }
variable "db_password" {
  type      = string
  sensitive = true
}

variable "common_tags" { type = map(string) }

# Optional overrides (sandbox-friendly defaults)
variable "db_engine_version" {
  type        = string
  default     = "17.4"
  description = "PostgreSQL version"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro" # fallback: db.t4g.micro (ARM) if quota/availability issues
}

variable "multi_az" {
  type    = bool
  default = false # Single-AZ for student sandbox
}
