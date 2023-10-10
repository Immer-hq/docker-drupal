#!/bin/bash
set -e

# Setup XDebug if remote IP is set.
# A remote IP can be obtained by creating a new loopback interface:
# sudo ifconfig lo0 alias 10.254.254.254
if [ -n "$XDEBUG_REMOTE_IP" ]; then
  phpenmod xdebug
  echo "Setting up XDebug on $XDEBUG_REMOTE_IP"
  echo "xdebug.remote_enable=1" >> /etc/php/7.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.remote_host=\"$XDEBUG_REMOTE_IP\"" >> /etc/php/7.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.remote_port=9000" >> /etc/php/7.1/apache2/conf.d/20-xdebug.ini
  echo "xdebug.idekey=phpstorm_xdebug" >> /etc/php/7.1/apache2/conf.d/20-xdebug.ini
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
