#!/bin/bash
set -e

# Enable XDebug if needed.
if [ -n "$XDEBUG_ENABLE" ]; then
  phpenmod xdebug
  echo "xdebug.profiler_enable=1" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.remote_handler=dbgp" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.remote_mode=req" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.client_host=host.docker.internal" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.client_port=9003" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.mode=debug" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.remote_autostart=1" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.remote_connect_back=0" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.idekey=PHPSTORM" >> /etc/php/8.1/apache2/conf.d/20-xdebug.ini
fi

# Setup mail.
if [ -n "$SMTP_HOST" ]; then
  echo "defaults" > /etc/msmtprc
  echo "tls $SMTP_AUTH" >> /etc/msmtprc
  echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> /etc/msmtprc
  echo "logfile /var/log/msmtp.log" >> /etc/msmtprc
  echo "" >> /etc/msmtprc
  echo "account mailgun" >> /etc/msmtprc
  echo "host $SMTP_HOST" >> /etc/msmtprc
  echo "port $SMTP_PORT" >> /etc/msmtprc
  echo "auth $SMTP_AUTH" >> /etc/msmtprc
  echo "user $SMTP_USER" >> /etc/msmtprc
  echo "password $SMTP_PASS" >> /etc/msmtprc
  echo "from $SMTP_FROM" >> /etc/msmtprc
  echo "" >> /etc/msmtprc
  echo "account default : mailgun" >> /etc/msmtprc
fi

if [ -f "/var/scripts/pre-startup.sh" ]; then
  /var/scripts/pre-startup.sh
fi

echo "export environment='${environment}'" >> /etc/apache2/envvars
rm -f /var/run/apache2/apache2.pid
exec apachectl -d /etc/apache2 -f apache2.conf -e info -DFOREGROUND
