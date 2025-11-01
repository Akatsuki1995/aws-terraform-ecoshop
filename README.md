# EcoShop – AWS 3-Tier (Terraform, Sandbox-Friendly)

## What this deploys
- VPC (10.0.0.0/16), 6 subnets across 2 AZs (web/app/db tiers)
- IGW + 1 NAT Gateway (cost-aware) + route tables
- Security Groups (least privilege: Web→App 8080, App→DB 5432, SSH only via Bastion)
- Bastion host in public subnet
- App tier as Auto Scaling Group (min=2) with Apache/PHP (shows hostname)
- Application Load Balancer (HTTP:80) with health check `/index.php`
- RDS PostgreSQL **Single-AZ** (sandbox compatible), **private only**

## Before you run
1. **Rotate any exposed AWS keys** immediately.
2. Create a named CLI profile (optional):
   ```bash
   aws configure --profile ecoshop
