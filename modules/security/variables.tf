###############################################################################
# Variables for security module
###############################################################################
variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidr" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

variable "project" {
  description = "Project name prefix used for resource naming"
  type        = string
}
