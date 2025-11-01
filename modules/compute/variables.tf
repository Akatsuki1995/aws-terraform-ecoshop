###############################################################################
# Variables for compute module
###############################################################################
variable "project" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "private_app_subnet_ids" { type = list(string) }
variable "bastion_sg_id" { type = string }
variable "app_sg_id" { type = string }
variable "key_name" { type = string }

variable "app_min_size" { type = number }
variable "app_max_size" { type = number }
variable "app_desired_capacity" { type = number }

variable "user_data_path" { type = string }
variable "common_tags" { type = map(string) }
