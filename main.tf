###############################################################################
# Root composition file: wires all modules together
# - Sets global common tags
# - Passes subnet/CIDR/AZ/Security/IDs between modules
###############################################################################

locals {
  # Common tags to keep resources organized
  common_tags = {
    Project = var.project
    Env     = "prod"
    Owner   = "student"
  }
}

# --- Network: VPC, subnets, IGW, NAT, routes --------------------------------
module "network" {
  source              = "./modules/network"
  project             = var.project
  vpc_cidr            = var.vpc_cidr
  azs                 = var.azs
  public_subnets      = var.public_subnets
  private_app_subnets = var.private_app_subnets
  private_db_subnets  = var.private_db_subnets
  common_tags         = local.common_tags
}

# --- Security Groups: least privilege between tiers --------------------------
module "security" {
  source           = "./modules/security"
  vpc_id           = module.network.vpc_id
  allowed_ssh_cidr = var.allowed_ssh_cidr
  common_tags      = local.common_tags
  project          = var.project

}

# --- Compute: Bastion instance + App Launch Template + AutoScaling Group -----
module "compute" {
  source                 = "./modules/compute"
  project                = var.project
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  private_app_subnet_ids = module.network.private_app_subnet_ids
  bastion_sg_id          = module.security.sg_bastion_id
  app_sg_id              = module.security.sg_app_id
  key_name               = var.key_name

  app_min_size         = var.app_min_size
  app_max_size         = var.app_max_size
  app_desired_capacity = var.app_desired_capacity

  user_data_path = "./modules/compute/files/user_data.sh"
  common_tags    = local.common_tags
}

# --- ALB: Internet-facing, forwards HTTP:80 to target group ------------------
module "alb" {
  source            = "./modules/alb"
  project           = var.project
  vpc_id            = module.network.vpc_id
  alb_sg_id         = module.security.sg_web_id
  public_subnet_ids = module.network.public_subnet_ids
  target_group_port = 80
  health_check_path = "/index.php"
  asg_name          = module.compute.app_asg_name
  common_tags       = local.common_tags
}

# --- RDS: PostgreSQL, Single-AZ (sandbox-friendly), private only -------------
module "rds" {
  source        = "./modules/rds"
  project       = var.project
  vpc_id        = module.network.vpc_id
  db_subnet_ids = module.network.private_db_subnet_ids
  sg_db_id      = module.security.sg_db_id
  db_username   = var.db_username
  db_password   = var.db_password
  common_tags   = local.common_tags
}
