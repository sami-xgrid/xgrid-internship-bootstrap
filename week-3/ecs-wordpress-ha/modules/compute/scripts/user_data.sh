#!/bin/bash
echo ECS_CLUSTER=${cluster_name} >> /etc/ecs/ecs.config
mkdir -p /var/www/wordpress_data
chown -R 33:33 /var/www/wordpress_data
chmod 755 /var/www/wordpress_data
