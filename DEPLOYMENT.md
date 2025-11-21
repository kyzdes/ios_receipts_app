# Deployment Guide - Recipe Manager

Complete guide for deploying the Recipe Manager application to an Ubuntu VPS.

## Prerequisites

- Ubuntu 20.04+ VPS
- Domain name (optional, for HTTPS)
- Root or sudo access
- Minimum 2GB RAM, 20GB storage

## Server Setup

### 1. Update System

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Install Dependencies

```bash
# Install Node.js 18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install PostgreSQL
sudo apt install -y postgresql postgresql-contrib

# Install Docker & Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo apt install -y docker-compose

# Install Nginx
sudo apt install -y nginx

# Install certbot for SSL
sudo apt install -y certbot python3-certbot-nginx
```

### 3. Configure PostgreSQL

```bash
# Switch to postgres user
sudo -u postgres psql

# Create database and user
CREATE DATABASE recipe_manager;
CREATE USER recipe_user WITH ENCRYPTED PASSWORD 'your_secure_password';
GRANT ALL PRIVILEGES ON DATABASE recipe_manager TO recipe_user;
\q
```

### 4. Configure Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## Application Deployment

### Option 1: Docker Deployment (Recommended)

1. **Clone Repository:**
```bash
cd /opt
sudo git clone <your-repository-url> recipe-app
cd recipe-app
```

2. **Configure Environment:**
```bash
cp backend/.env.example .env
sudo nano .env
```

Edit the environment variables:
```env
NODE_ENV=production
PORT=3000
DB_HOST=postgres
DB_NAME=recipe_manager
DB_USER=recipe_user
DB_PASSWORD=your_secure_password
JWT_SECRET=your_very_long_random_secret_key
JWT_REFRESH_SECRET=your_very_long_random_refresh_secret_key
```

3. **Start Services:**
```bash
sudo docker-compose up -d
```

4. **Run Migrations:**
```bash
sudo docker-compose exec backend npm run migrate
```

5. **Check Status:**
```bash
sudo docker-compose ps
sudo docker-compose logs -f backend
```

### Option 2: PM2 Deployment

1. **Clone Repository:**
```bash
cd /opt
sudo git clone <your-repository-url> recipe-app
cd recipe-app/backend
```

2. **Install Dependencies:**
```bash
npm ci --production
```

3. **Configure Environment:**
```bash
cp .env.example .env
sudo nano .env
```

4. **Run Migrations:**
```bash
npm run migrate
```

5. **Install PM2:**
```bash
sudo npm install -g pm2
```

6. **Start Application:**
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 startup
```

## Nginx Configuration

### 1. Create Nginx Configuration

```bash
sudo nano /etc/nginx/sites-available/recipe-api
```

Add configuration:
```nginx
server {
    listen 80;
    server_name your-domain.com;

    client_max_body_size 10M;

    location /api/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    location /uploads/ {
        alias /opt/recipe-app/backend/uploads/;
        expires 7d;
        add_header Cache-Control "public, immutable";
    }

    location /health {
        proxy_pass http://localhost:3000/health;
        access_log off;
    }
}
```

### 2. Enable Site

```bash
sudo ln -s /etc/nginx/sites-available/recipe-api /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

## SSL Configuration with Let's Encrypt

```bash
sudo certbot --nginx -d your-domain.com

# Auto-renewal
sudo certbot renew --dry-run
```

## Database Backup

### 1. Create Backup Script

```bash
sudo nano /opt/recipe-app/backup.sh
```

Add content:
```bash
#!/bin/bash
BACKUP_DIR="/opt/backups/recipe-db"
mkdir -p $BACKUP_DIR
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/recipe_db_$TIMESTAMP.sql"

pg_dump -h localhost -U recipe_user recipe_manager > $BACKUP_FILE
gzip $BACKUP_FILE

# Delete backups older than 30 days
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_FILE.gz"
```

### 2. Make Executable and Schedule

```bash
sudo chmod +x /opt/recipe-app/backup.sh

# Add to crontab (daily at 2 AM)
sudo crontab -e
0 2 * * * /opt/recipe-app/backup.sh >> /var/log/recipe-backup.log 2>&1
```

## Monitoring

### 1. PM2 Monitoring (if using PM2)

```bash
pm2 monit
pm2 list
pm2 logs
```

### 2. Docker Monitoring (if using Docker)

```bash
docker-compose logs -f
docker-compose ps
docker stats
```

### 3. System Monitoring

```bash
# Install monitoring tools
sudo apt install -y htop

# View logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

## Maintenance

### Update Application

#### Docker:
```bash
cd /opt/recipe-app
sudo git pull
sudo docker-compose down
sudo docker-compose build
sudo docker-compose up -d
```

#### PM2:
```bash
cd /opt/recipe-app
sudo git pull
cd backend
npm ci --production
pm2 restart all
```

### Database Maintenance

```bash
# Vacuum and analyze
sudo -u postgres psql -d recipe_manager -c "VACUUM ANALYZE;"

# Restore from backup
gunzip < backup_file.sql.gz | sudo -u postgres psql recipe_manager
```

## Security Hardening

### 1. Secure PostgreSQL

```bash
sudo nano /etc/postgresql/*/main/pg_hba.conf
# Ensure only local connections are allowed
```

### 2. Configure Fail2Ban

```bash
sudo apt install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

### 3. Regular Updates

```bash
# Create update script
sudo nano /opt/scripts/system-update.sh
```

```bash
#!/bin/bash
apt update
apt upgrade -y
apt autoremove -y
```

Schedule weekly:
```bash
sudo crontab -e
0 3 * * 0 /opt/scripts/system-update.sh
```

## Troubleshooting

### Check Application Status

```bash
# PM2
pm2 status
pm2 logs --lines 100

# Docker
docker-compose ps
docker-compose logs backend --tail=100

# Nginx
sudo nginx -t
sudo systemctl status nginx
```

### Database Connection Issues

```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connections
sudo -u postgres psql -c "SELECT * FROM pg_stat_activity;"
```

### Permission Issues

```bash
# Fix upload directory permissions
sudo chown -R www-data:www-data /opt/recipe-app/backend/uploads
sudo chmod -R 755 /opt/recipe-app/backend/uploads
```

## Performance Optimization

### 1. Enable Gzip in Nginx

```nginx
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/json application/javascript;
```

### 2. PostgreSQL Tuning

```bash
sudo nano /etc/postgresql/*/main/postgresql.conf
```

Adjust based on server resources:
```conf
shared_buffers = 256MB
effective_cache_size = 1GB
work_mem = 16MB
maintenance_work_mem = 128MB
```

### 3. PM2 Cluster Mode

```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'recipe-api',
    script: 'src/server.js',
    instances: 'max',  // Use all CPU cores
    exec_mode: 'cluster'
  }]
};
```

## Rollback Procedure

```bash
# Stop services
sudo docker-compose down
# or
pm2 stop all

# Restore database
gunzip < backup.sql.gz | sudo -u postgres psql recipe_manager

# Revert code
git checkout <previous-commit-hash>

# Restart services
sudo docker-compose up -d
# or
pm2 restart all
```

## Support

For issues or questions:
1. Check application logs
2. Verify environment configuration
3. Check database connectivity
4. Review Nginx error logs
5. Consult documentation

---

**Important:** Always test deployments in a staging environment before deploying to production.
