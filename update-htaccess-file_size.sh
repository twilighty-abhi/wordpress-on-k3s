#!/bin/bash

# WordPress .htaccess PHP Configuration Script
# Usage: ./update-htaccess.sh [NAMESPACE]
# used o imcrease the space of each worpress instance from 2MB to 128MB

NAMESPACE=${1:-wp-dev}

echo "🔧 Updating .htaccess for WordPress in namespace: $NAMESPACE"

# Get WordPress pod name
POD_NAME=$(sudo kubectl get pods -n $NAMESPACE -l app=wordpress -o jsonpath='{.items[0].metadata.name}')

if [ -z "$POD_NAME" ]; then
    echo "❌ No WordPress pods found in namespace $NAMESPACE"
    exit 1
fi

echo "📝 Found WordPress pod: $POD_NAME"

# Backup existing .htaccess
echo "💾 Creating backup..."
sudo kubectl exec -n $NAMESPACE $POD_NAME -- cp /var/www/html/.htaccess /var/www/html/.htaccess.backup 2>/dev/null || echo "No existing .htaccess found"

# Create new .htaccess with PHP settings
echo "⚙️ Applying PHP configuration..."
sudo kubectl exec -n $NAMESPACE $POD_NAME -- bash -c 'cat > /var/www/html/.htaccess << "EOF"
# PHP Configuration
php_value upload_max_filesize 128M
php_value post_max_size 128M
php_value memory_limit 256M
php_value max_execution_time 300
php_value max_input_time 300

# BEGIN WordPress
# The directives (lines) between "BEGIN WordPress" and "END WordPress" are
# dynamically generated, and should only be modified via WordPress filters.
# Any changes to the directives between these markers will be overwritten.
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>

# END WordPress
EOF'

# Set proper permissions
sudo kubectl exec -n $NAMESPACE $POD_NAME -- chown www-data:www-data /var/www/html/.htaccess
sudo kubectl exec -n $NAMESPACE $POD_NAME -- chmod 644 /var/www/html/.htaccess

echo "✅ .htaccess updated successfully!"
echo ""
echo "📋 Applied PHP Settings:"
echo "  • upload_max_filesize: 128M"
echo "  • post_max_size: 128M" 
echo "  • memory_limit: 256M"
echo "  • max_execution_time: 300"
echo "  • max_input_time: 300"
echo ""
echo "🔍 To verify: sudo kubectl exec -n $NAMESPACE $POD_NAME -- cat /var/www/html/.htaccess"
