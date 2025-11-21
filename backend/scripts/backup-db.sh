#!/bin/bash

# Database backup script
# Usage: ./backup-db.sh

# Load environment variables
source .env

# Backup directory
BACKUP_DIR="./backups"
mkdir -p $BACKUP_DIR

# Timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/recipe_db_$TIMESTAMP.sql"

# Create backup
echo "Creating database backup..."
PGPASSWORD=$DB_PASSWORD pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME > $BACKUP_FILE

if [ $? -eq 0 ]; then
    echo "Backup created successfully: $BACKUP_FILE"

    # Compress backup
    gzip $BACKUP_FILE
    echo "Backup compressed: $BACKUP_FILE.gz"

    # Delete backups older than 30 days
    find $BACKUP_DIR -name "*.gz" -mtime +30 -delete
    echo "Old backups cleaned up"
else
    echo "Backup failed!"
    exit 1
fi
