###############################################################################
# Terraform + AWS provider versions and configuration
# - Locks Terraform & aws provider versions
# - Reads region/profile from variables or env (AWS_PROFILE)
###############################################################################
terraform {
  required_version = ">= 1.5.0" # ensure modern Terraform features
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50" # stable recent v5
    }
  }
}

provider "aws" {
  region = var.region # set via tfvars (envs/prod.tfvars)
  # profile = "ecoshop"                    # optional: uncomment to force a profile
}
