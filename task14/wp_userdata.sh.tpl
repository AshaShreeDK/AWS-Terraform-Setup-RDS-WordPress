#!/bin/bash
# Update the system and install required packages
yum update -y
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
yum install -y httpd mariadb

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Download and extract WordPress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
cp wordpress/wp-config-sample.php wordpress/wp-config.php

# Configure WordPress with the provided DB credentials and endpoint
sed -i 's/database_name_here/wordpressdb/' wordpress/wp-config.php
sed -i "s/username_here/${db_username}/" wordpress/wp-config.php
sed -i "s/password_here/${db_password}/" wordpress/wp-config.php
sed -i "s/localhost/${db_host}/" wordpress/wp-config.php

# Restart Apache to apply changes
systemctl restart httpd

