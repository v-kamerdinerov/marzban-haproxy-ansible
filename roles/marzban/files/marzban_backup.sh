#!/bin/bash

# Log file
LOG_FILE="/var/log/marzban-backuper.log"

# Colors for logging
FontColor_Red="\033[31m"
FontColor_Green="\033[32m"
FontColor_Yellow="\033[33m"
FontColor_Suffix="\033[0m"

# Directories to backup
LIB_SRC_DIR="/var/lib/marzban/*"
OPT_SRC_DIR="/opt/marzban/*"

# Backup directory
BACKUP_DIR="/var/lib/marzban_backups"

# Environment file
ENV_FILE="/opt/marzban/.env"

# Get current date
CURRENT_DATE=$(date +"%Y-%m-%d_%H-%M-%S")
HOSTNAME_NODE=$(hostname)

# Logging function with levels and colors
log() {
    LEVEL="$1"
    MSG="$2"
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    case "${LEVEL}" in
        INFO)
            printf "[${TIMESTAMP}] [${FontColor_Green}${LEVEL}${FontColor_Suffix}] %s\n" "${MSG}" | tee -a "$LOG_FILE"
            ;;
        WARN)
            printf "[${TIMESTAMP}] [${FontColor_Yellow}${LEVEL}${FontColor_Suffix}] %s\n" "${MSG}" | tee -a "$LOG_FILE"
            ;;
        ERROR)
            printf "[${TIMESTAMP}] [${FontColor_Red}${LEVEL}${FontColor_Suffix}] %s\n" "${MSG}" | tee -a "$LOG_FILE" >&2
            ;;
        *)
            printf "[${TIMESTAMP}] %s\n" "${MSG}" | tee -a "$LOG_FILE"
            ;;
    esac
}

# Function to create backup directory
create_backup_dir() {
    if [ ! -d "$BACKUP_DIR" ]; then
        log INFO "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi
}

# Function to backup directories
backup_directories() {
    create_backup_dir
    BACKUP_PATH="$BACKUP_DIR/backup_$CURRENT_DATE"
    log INFO "Backing up directories to $BACKUP_PATH"

    # Create directory structure for backup
    mkdir -p "$BACKUP_PATH/lib"
    mkdir -p "$BACKUP_PATH/opt"

    # Backup contents
    cp -r $LIB_SRC_DIR "$BACKUP_PATH/lib/" || log WARN "Failed to backup lib directory."
    cp -r $OPT_SRC_DIR "$BACKUP_PATH/opt/" || log WARN "Failed to backup opt directory."

    log INFO "Directories backed up successfully."
}

# Function to backup MySQL databases
backup_databases() {
    if grep -q "SQLALCHEMY_DATABASE_URL" "$ENV_FILE" && ! grep -q "sqlite" "$ENV_FILE"; then
        # Fixed user root
        DB_USER="root"

        # Extract root password from environment file
        DB_PASSWORD=$(grep -oP '(?<=ROOT_PASSWORD=).*' "$ENV_FILE")

        # Install mysqldump if not installed
        if ! command -v mysqldump &> /dev/null; then
            log WARN "mysqldump not found, installing..."
            apt-get update && apt-get install -y mysql-client || log ERROR "Failed to install mysql-client."
        fi

        # Dump databases
        DB_BACKUP_PATH="$BACKUP_PATH/db-backup"
        mkdir -p "$DB_BACKUP_PATH"

        # Get the list of databases and exclude system databases
        databases=$(mysql -h 127.0.0.1 --user="$DB_USER" --password="$DB_PASSWORD" -e "SHOW DATABASES;" | tr -d "| " | grep -v -E 'Database|information_schema|mysql|performance_schema|sys')

        for db in $databases; do
            log INFO "Dumping database: $db"
            # Use additional parameters to avoid errors
            mysqldump -h 127.0.0.1 --force --opt --user="$DB_USER" --password="$DB_PASSWORD" --single-transaction --skip-lock-tables --no-tablespaces --databases "$db" > "$DB_BACKUP_PATH/$db.sql" || log ERROR "Getting some error while dump database: $db"
        done
        log INFO "Databases dumped successfully."
    else
        log INFO "SQLite detected or SQLALCHEMY_DATABASE_URL not found. No MySQL databases to backup."
    fi
}

# Function to send backup to Telegram
send_to_telegram() {
    # Extract Telegram bot token and chat ID from environment file
    TELEGRAM_BOT_TOKEN=$(grep -oP '(?<=TELEGRAM_BOT_TOKEN=).*' "$ENV_FILE")
    TELEGRAM_CHAT_ID=$(grep -oP '(?<=TELEGRAM_CHAT_ID=).*' "$ENV_FILE")

    if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        TAR_FILE="$BACKUP_DIR/backup_$CURRENT_DATE.tar.gz"
        log INFO "Creating tarball $TAR_FILE"
        tar -czf "$TAR_FILE" -C "$BACKUP_DIR" "backup_$CURRENT_DATE" || log ERROR "Failed to create tarball."

        log INFO "Sending backup to Telegram chat ID $TELEGRAM_CHAT_ID"
        curl -F chat_id="${TELEGRAM_CHAT_ID}" \
             -F caption="Backup from $HOSTNAME_NODE at $CURRENT_DATE" \
             -F parse_mode="HTML" \
             -F document=@"$TAR_FILE" \
             https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendDocument || log ERROR "Failed to send backup to Telegram."

        log INFO "Backup sent to Telegram successfully."
    else
        log WARN "Telegram BOT token or chat ID not provided. Skipping upload."
    fi
}

# Main backup process
main() {
    log INFO "Starting backup process."
    backup_directories
    backup_databases
    send_to_telegram
    log INFO "Backup process completed."
}

# Run the main process
main
