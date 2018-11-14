#!/bin/sh

FILENAME=$BACKUP_NAME.$(date +"%Y%m%d-%H%M%S").zip
echo Backing up to $FILENAME
cd /source
zip -r9 /target/$FILENAME .
touch /target/$fILENAME

# Clean up old logs
echo Cleaning old backups
ls -1tr /target/$BACKUP_NAME.* | head -n -$BACKUP_COUNT | xargs -r rm -f --
