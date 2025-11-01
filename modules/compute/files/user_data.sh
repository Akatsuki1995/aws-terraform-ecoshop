#!/bin/bash
# Update system and install Apache + PHP
yum update -y
yum install -y httpd php

# Create a test PHP page
echo "<?php echo '<h1>EcoShop App - '.gethostname().'</h1>'; ?>" > /var/www/html/index.php

# Change Apache to listen on port 8080 (to match Terraform security rules)
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf

# Enable and start Apache at boot
systemctl enable httpd
systemctl start httpd
