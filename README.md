# WordPress on K3s

A comprehensive one-click deployment script to deploy WordPress on K3s (Lightweight Kubernetes) with enterprise-grade features including persistent storage, SSL/TLS certificates, and production-ready configurations.

## 🚀 Features

- **Persistent Storage**: Automatic PVC (Persistent Volume Claims) setup for WordPress files and MariaDB data
- **MariaDB Database**: Dedicated MariaDB instance with persistent storage and secure credentials
- **SSL/TLS Support**: Automatic SSL certificate provisioning with cert-manager and Let's Encrypt
- **Ingress Controller**: Built-in Traefik ingress controller for routing and load balancing
- **Resource Management**: Configured resource limits and requests for optimal performance
- **High Availability**: WordPress deployed with 2 replicas for redundancy
- **Security**: Automatically generated secure passwords for database and WordPress admin
- **Namespace Isolation**: Each deployment runs in its own Kubernetes namespace

## 📋 Prerequisites

- **Operating System**: Linux-based system (Ubuntu/Debian recommended)
- **Root/Sudo Access**: Required for K3s installation and Kubernetes operations
- **Domain Name**: A valid domain name pointing to your server's IP address
- **Network Access**: Internet connectivity for downloading components and SSL certificate issuance
- **Minimum Resources**: 
  - 2GB RAM
  - 20GB available disk space
  - 2 CPU cores (recommended)

## 🛠️ Installation & Usage

### Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/twilighty-abhi/wordpress-on-k3s.git
   cd wordpress-on-k3s
   ```

2. **Make the script executable:**
   ```bash
   chmod +x wordpress-k3s.sh
   ```

3. **Run the deployment:**
   ```bash
   ./wordpress-k3s.sh your-domain.com
   ```

### Usage Syntax

```bash
./wordpress-k3s.sh [DOMAIN] [NAMESPACE]
```

**Parameters:**
- `DOMAIN` (required): Domain name for your WordPress site
- `NAMESPACE` (optional): Kubernetes namespace (default: auto-generated from domain)

### Examples

```bash
# Basic deployment with auto-generated namespace
./wordpress-k3s.sh blog.example.com

# Custom namespace deployment
./wordpress-k3s.sh blog.example.com my-wordpress-site

# Get help and see all options
./wordpress-k3s.sh --help
```

### What the Script Does

1. **Environment Setup**: Installs K3s if not already present
2. **Namespace Creation**: Creates isolated Kubernetes namespace
3. **Storage Provisioning**: Sets up persistent volumes for WordPress and database
4. **Database Deployment**: Deploys MariaDB with secure configuration
5. **WordPress Deployment**: Deploys WordPress with optimized settings
6. **Ingress Configuration**: Sets up Traefik ingress with SSL/TLS
7. **Certificate Management**: Configures Let's Encrypt SSL certificates
8. **Credential Generation**: Creates and saves secure passwords

## 🔧 Configuration

### Generated Directory Structure

The script creates a deployment directory at:
```
/home/frappe/k3s-wordpress-{domain}/
├── credentials.txt       # Generated passwords and connection details
├── secrets.yaml         # Kubernetes secrets
├── pvc.yaml             # Persistent volume claims
├── mariadb.yaml         # MariaDB deployment
├── wordpress.yaml       # WordPress deployment
└── ingress.yaml         # Ingress configuration
```

### Environment Variables

The script automatically configures:
- `WORDPRESS_DB_HOST`: MariaDB service endpoint
- `WORDPRESS_DB_NAME`: Database name (wordpress)
- `WORDPRESS_DB_USER`: Database user (wordpress)
- `WORDPRESS_DB_PASSWORD`: Auto-generated secure password

## 📊 Post-Deployment

### Accessing Your Site

1. **Wait for SSL Certificate**: SSL certificate provisioning may take 2-5 minutes
2. **Access WordPress**: Visit `https://your-domain.com`
3. **Admin Setup**: Use the generated admin password from `credentials.txt`

### Generated Credentials

After deployment, find your credentials in:
```
/home/frappe/k3s-wordpress-{domain}/credentials.txt
```

Contains:
- WordPress admin password
- Database password
- Useful management commands

## 🔍 Management Commands

### View Deployment Status
```bash
# Check all resources in your namespace
sudo kubectl get all -n your-namespace

# View pod status
sudo kubectl get pods -n your-namespace

# Check persistent volumes
sudo kubectl get pvc -n your-namespace

# View ingress status
sudo kubectl get ingress -n your-namespace
```

### Monitor Logs
```bash
# WordPress logs
sudo kubectl logs -f deployment/wordpress -n your-namespace

# MariaDB logs
sudo kubectl logs -f deployment/mariadb -n your-namespace
```

### Scale WordPress
```bash
# Scale to 3 replicas
sudo kubectl scale deployment wordpress --replicas=3 -n your-namespace

# Scale to 1 replica
sudo kubectl scale deployment wordpress --replicas=1 -n your-namespace
```

### Update Configuration
```bash
# Edit WordPress deployment
sudo kubectl edit deployment wordpress -n your-namespace

# Edit MariaDB deployment
sudo kubectl edit deployment mariadb -n your-namespace
```

## 🗑️ Cleanup

### Remove Deployment
```bash
# Delete entire deployment (WARNING: This removes all data)
sudo kubectl delete namespace your-namespace
```

### Backup Before Removal
```bash
# Backup WordPress files
sudo kubectl exec -n your-namespace deployment/wordpress -- tar -czf /tmp/wordpress-backup.tar.gz /var/www/html

# Copy backup to host
sudo kubectl cp your-namespace/wordpress-pod:/tmp/wordpress-backup.tar.gz ./wordpress-backup.tar.gz
```

## 🚨 Troubleshooting

### Common Issues

**1. Domain not resolving:**
- Ensure DNS A record points to your server IP
- Wait for DNS propagation (up to 24 hours)

**2. SSL certificate not issued:**
- Check cert-manager logs: `sudo kubectl logs -f deployment/cert-manager -n cert-manager`
- Verify domain accessibility on port 80

**3. WordPress not starting:**
- Check pod logs: `sudo kubectl logs -f deployment/wordpress -n your-namespace`
- Verify MariaDB is running: `sudo kubectl get pods -n your-namespace`

**4. Database connection issues:**
- Ensure MariaDB pod is ready: `sudo kubectl get pods -n your-namespace`
- Check secrets: `sudo kubectl get secrets -n your-namespace`

### Debug Commands
```bash
# Check K3s status
sudo systemctl status k3s

# View all events in namespace
sudo kubectl get events -n your-namespace

# Describe problematic pods
sudo kubectl describe pod pod-name -n your-namespace

# Check ingress controller
sudo kubectl get pods -n kube-system | grep traefik
```

### Log Locations
- K3s logs: `sudo journalctl -u k3s -f`
- Container logs: `sudo kubectl logs -f pod-name -n your-namespace`

## 📝 Notes

- The script requires sudo privileges for K3s operations
- Generated passwords are cryptographically secure (32 characters)
- WordPress runs with PHP-FPM and optimized settings
- MariaDB uses version 10.11 for stability and performance
- All data persists across pod restarts via PVCs

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is open source and available under standard licensing terms.
