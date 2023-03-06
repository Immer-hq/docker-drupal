#!/bin/bash

if [ -z "$SKIP_BACKUP" ]; then
  for x in `ls /var/www/web/sites`; do
    if [ -f "/var/www/web/sites/$x/settings.php" ]; then
      cd /var/www/web/sites/$x
      if [ -f "/backup/$x.tar.gz" ]; then
        tar -xzf /backup/$x.tar.gz
      else
        if [ -f "/backup/files.tar.gz" ]; then
          tar -xzf /backup/files.tar.gz
        fi
      fi
    fi
  done
fi
