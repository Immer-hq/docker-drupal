#!/bin/bash

if [ -x /var/www/vendor/bin/phpcs ]; then
  /var/www/vendor/bin/phpcs --ignore=*.css,*.min.js,*.js --standard=/var/www/vendor/drupal/coder/coder_sniffer/Drupal /var/www/web/modules/custom /var/www/web/themes
fi
