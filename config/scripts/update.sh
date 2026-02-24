#!/bin/bash

set -e

cd /var/www/web;

if [ -f "/var/scripts/pre-update.php" ]; then
  /var/scripts/pre-update.php
fi

for x in `ls /var/www/web/sites`; do
  if [ -f "/var/www/web/sites/$x/settings.php" ]; then
    drush -l $x deploy
    if [ -f "../translations/nl.po" ]; then
      drush locale:import nl ../translations/nl.po | cat
      drush -l $x cr
    fi
  fi
done

if [ -f "/var/scripts/post-update.php" ]; then
  /var/scripts/post-update.php
fi
