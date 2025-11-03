#!/usr/bin/env bash
# === Smart Backup Script ===
# Features: Logging, Lockfile, Checksum verification, Dry run
# Author: You :)

set -euo pipefail

# --- Setup paths and load config ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/backup.config"

if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
else
  echo "Error: Config file not found at $CONFIG_FILE"
  exit 1
fi

# --- Helper: Logging ---
log() {
  local level="$1"; shift
  local msg="$*"
  local time
  time=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$time] $level: $msg" | tee -a "$LOG_FILE"
}

# --- Helper: Cleanup on exit ---
cleanup() {
  if [[ -f "$LOCK_FILE" ]]; then
    rm -f "$LOCK_FILE"
    log "INFO" "Lock file removed"
  fi
}
trap cleanup EXIT

# --- Prevent multiple runs ---
if [[ -f "$LOCK_FILE" ]]; then
  log "ERROR" "Lock file exists. Another backup may be running."
  exit 1
fi
touch "$LOCK_FILE"

# --- Check arguments ---
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 [--dry-run] /path/to/source_folder"
  exit 1
fi

DRY_RUN=false
SOURCE_DIR=""

if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  SOURCE_DIR="$2"
else
  SOURCE_DIR="$1"
fi

if [[ ! -d "$SOURCE_DIR" ]]; then
  log "ERROR" "Source folder not found: $SOURCE_DIR"
  exit 1
fi

# --- Ensure destination exists ---
mkdir -p "$BACKUP_DESTINATION"

# --- Timestamp & filenames ---
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_NAME="backup-$TIMESTAMP.tar.gz"
BACKUP_PATH="$BACKUP_DESTINATION/$BACKUP_NAME"
CHECKSUM_PATH="$BACKUP_PATH.sha256"

# --- Exclusions ---
IFS=',' read -r -a EXCLUDES <<< "$EXCLUDE_PATTERNS"
EXCLUDE_ARGS=()
for pattern in "${EXCLUDES[@]}"; do
  EXCLUDE_ARGS+=(--exclude="$pattern")
done

# --- Dry Run ---
if $DRY_RUN; then
  log "INFO" "[DRY RUN] Would create backup: $BACKUP_NAME"
  log "INFO" "[DRY RUN] Would exclude: ${EXCLUDES[*]}"
  log "INFO" "[DRY RUN] Would save to: $BACKUP_DESTINATION"
  log "INFO" "[DRY RUN] Would generate checksum file"
  exit 0
fi

# --- Start Backup ---
log "INFO" "Starting backup of $SOURCE_DIR"
tar -czf "$BACKUP_PATH" "${EXCLUDE_ARGS[@]}" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"
log "SUCCESS" "Backup created: $BACKUP_PATH"

# --- Create checksum ---
$CHECKSUM_CMD "$BACKUP_PATH" > "$CHECKSUM_PATH"
log "INFO" "Checksum created: $CHECKSUM_PATH"

# --- Verify checksum ---
log "INFO" "Verifying backup integrity..."
if $CHECKSUM_CMD -c "$CHECKSUM_PATH" &>/dev/null; then
  log "SUCCESS" "Checksum verification passed."
else
  log "ERROR" "Checksum verification FAILED!"
  exit 1
fi

# --- Test archive extraction ---
TEMP_DIR=$(mktemp -d)
if tar -tzf "$BACKUP_PATH" > /dev/null 2>&1; then
  log "SUCCESS" "Archive test extraction passed."
else
  log "ERROR" "Archive extraction failed (file may be corrupted)."
  rm -rf "$TEMP_DIR"
  exit 1
fi
rm -rf "$TEMP_DIR"

# --- Delete Old Backups (Rotation) ---
delete_old_backups() {
  log "INFO" "Starting cleanup of old backups..."

  cd "$BACKUP_DESTINATION" || return

  # Get all backup files sorted by date (newest first)
  backups=( $(ls -1 backup-*.tar.gz 2>/dev/null | sort -r) )

  if [[ ${#backups[@]} -eq 0 ]]; then
    log "INFO" "No backups to clean."
    return
  fi

  # --- Keep most recent daily backups ---
  daily_to_keep=("${backups[@]:0:$DAILY_KEEP}")

  # --- Extract weekly and monthly backups ---
  weekly_to_keep=()
  monthly_to_keep=()

  for file in "${backups[@]}"; do
    date_part=$(echo "$file" | grep -oP '\d{4}-\d{2}-\d{2}')
    week_id=$(date -d "$date_part" +%Y-%V)   # e.g. 2025-45
    month_id=$(date -d "$date_part" +%Y-%m)  # e.g. 2025-11

    if [[ ! " ${weekly_to_keep[*]} " =~ $week_id ]] && [[ ${#weekly_to_keep[@]} -lt $WEEKLY_KEEP ]]; then
      weekly_to_keep+=("$week_id")
    fi

    if [[ ! " ${monthly_to_keep[*]} " =~ $month_id ]] && [[ ${#monthly_to_keep[@]} -lt $MONTHLY_KEEP ]]; then
      monthly_to_keep+=("$month_id")
    fi
  done

  # --- Combine all files we want to keep ---
  keep_list=()
  for file in "${backups[@]}"; do
    date_part=$(echo "$file" | grep -oP '\d{4}-\d{2}-\d{2}')
    week_id=$(date -d "$date_part" +%Y-%V)
    month_id=$(date -d "$date_part" +%Y-%m)

    if [[ " ${daily_to_keep[*]} " =~ $file ]] ||
       [[ " ${weekly_to_keep[*]} " =~ $week_id ]] ||
       [[ " ${monthly_to_keep[*]} " =~ $month_id ]]; then
      keep_list+=("$file")
    fi
  done

  # --- Delete files not in keep list ---
  for file in "${backups[@]}"; do
    if [[ ! " ${keep_list[*]} " =~ $file ]]; then
      log "INFO" "Deleting old backup: $file"
      rm -f "$file" "$file.sha256"
    fi
  done

  log "INFO" "Cleanup complete."
}

delete_old_backups

log "INFO" "Backup completed successfully."

