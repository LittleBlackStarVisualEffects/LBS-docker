#!/bin/bash
# Backup script for AYON Postgres DB (Native Installation)
# Creates a SQL dump of the AYON database

# Working directory
cd /home/avril9960x/dockerdata/ayon-docker || exit

# Timestamp format
timestamp=$(date +"%d_%m_%Y_%H_%M_%S")

# Backup file name
backup_file="backup_ayon_${timestamp}.sql"

# Destination folder
backup_dir="/softwares/backup/avril9960x/ayon_db_backups"

# Ensure backup directory exists
mkdir -p "$backup_dir"

# Database connection details (from docker-compose.yml)
DB_HOST="localhost"
DB_PORT="5432"
DB_USER="ayon"
DB_PASS="ayon"
DB_NAME="ayon"

# Set PostgreSQL password in environment to avoid prompt
export PGPASSWORD="$DB_PASS"

# Create backup using psql via docker exec
# First, check if we can use the running postgres container
if docker ps | grep -q postgres; then
    echo "[$(date)] Attempting backup using Docker container..."
    docker exec postgres pg_dump -U "$DB_USER" "$DB_NAME" > "${backup_dir}/${backup_file}" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "${backup_dir}/${backup_file}" ]; then
        echo "[$(date)] ✓ Backup created: ${backup_dir}/${backup_file}"
        ls -lh "${backup_dir}/${backup_file}"
        exit 0
    fi
fi

# Alternative: Try direct psql connection if pg_dump is available
if command -v pg_dump &> /dev/null; then
    echo "[$(date)] Attempting backup using local pg_dump..."
    pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" "$DB_NAME" > "${backup_dir}/${backup_file}"
    
    if [ $? -eq 0 ] && [ -s "${backup_dir}/${backup_file}" ]; then
        echo "[$(date)] ✓ Backup created: ${backup_dir}/${backup_file}"
        ls -lh "${backup_dir}/${backup_file}"
        exit 0
    fi
fi

# Alternative: Try using docker exec with any postgres container
POSTGRES_CONTAINER=$(docker ps -q -f ancestor=postgres 2>/dev/null | head -1)
if [ -n "$POSTGRES_CONTAINER" ]; then
    echo "[$(date)] Attempting backup using container: $POSTGRES_CONTAINER..."
    docker exec "$POSTGRES_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "${backup_dir}/${backup_file}" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "${backup_dir}/${backup_file}" ]; then
        echo "[$(date)] ✓ Backup created: ${backup_dir}/${backup_file}"
        ls -lh "${backup_dir}/${backup_file}"
        exit 0
    fi
fi

echo "[$(date)] ✗ Backup failed: Could not access PostgreSQL"
echo "Please ensure one of the following:"
echo "  1. Start AYON with: docker compose up -d"
echo "  2. Install PostgreSQL client tools: sudo apt install postgresql-client"
echo "  3. Provide database connection details"

exit 1
