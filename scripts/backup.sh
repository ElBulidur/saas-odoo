#!/bin/bash
set -e

DATE=$(date +%Y-%m-%d_%H-%M)
BACKUP_DIR=/srv/odoo-saas/backups
BUCKET=saas-odoo-backups

mkdir -p $BACKUP_DIR

echo "[$DATE] Iniciando backup..."

# Dump do Postgres
docker exec db-odoo pg_dumpall -U odoo -p 5441 -p 5441 | gzip > $BACKUP_DIR/pg_$DATE.sql.gz

# Backup do filestore
tar -czf $BACKUP_DIR/filestore_$DATE.tar.gz -C /srv/odoo-saas/data/odoo .

# Envia para S3
aws s3 cp $BACKUP_DIR/pg_$DATE.sql.gz s3://$BUCKET/postgres/
aws s3 cp $BACKUP_DIR/filestore_$DATE.tar.gz s3://$BUCKET/filestore/

# Remove backups locais com mais de 3 dias
find $BACKUP_DIR -mtime +3 -delete

echo "[$DATE] Backup concluído!"
