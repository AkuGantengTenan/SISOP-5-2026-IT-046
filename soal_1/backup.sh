#!/bin/bash
TIMESTAMP=$(date +"%d%m%Y-%H%M%S")
BACKUP_NAME="farewell_backup_${TIMESTAMP}.zip"

echo "=> Mem-backup file ke ${BACKUP_NAME}..."
cd osboot
zip ${BACKUP_NAME} bzImage single.gz multi.gz farewell.iso

echo "=> Menghapus file original..."
rm bzImage single.gz multi.gz farewell.iso
cd ..
echo "=> Backup selesai."
