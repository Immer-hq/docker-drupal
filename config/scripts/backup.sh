#!/bin/bash

if [ -z "$SKIP_BACKUP" ]; then
  for x in `ls /var/www/web/sites`; do
    if [ -f "/var/www/web/sites/$x/settings.php" ]; then
      cd /var/www/web/sites/$x
      tar -czf /backup/$x.tar.gz files
    fi
  done
fi
