#!/bin/bash
# Backup script for AYON Postgres DB (Docker)
# Runs daily at 4 AM via cron

# Working directory
cd /home/avril9960x/dockerdata/ayon-docker || exit

# Timestamp format
timestamp=$(date +"%d_%m_%Y_%H_%M_%S")

# Backup file name
backup_file="backup_ayon_${timestamp}.sql"

# Destination folder
backup_dir="/softwares/backup/avril5950/ayon_db_backups"

# Ensure backup directory exists
mkdir -p "$backup_dir"

# Run pg_dump inside Docker Compose
docker compose exec -T postgres pg_dump -U ayon > "${backup_dir}/${backup_file}"

# Optional: log success message
echo "[$(date)] Backup created: ${backup_dir}/${backup_file}" >> /home/avril5950/ayon-docker/backup_cron.log

