FROM ubuntu:24.04

EXPOSE 80

ENV LANG=C.UTF-8 \
  SMTP_HOST=mailhog \
  SMTP_PORT=25 \
  SMTP_AUTH=off \
  SMTP_USER= \
  SMTP_PASS= \
  SMTP_FROM=noreply@example.com \
  DEBIAN_FRONTEND=noninteractive

RUN echo Europe/Paris | tee /etc/timezone \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y ca-certificates curl \
    lsb-release gnupg2 ca-certificates \
    apt-transport-https software-properties-common \
  && add-apt-repository -y ppa:ondrej/php \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    apache2 php7.1 libapache2-mod-php7.1 php7.1-memcached \
    php7.1-mbstring php7.1-xml php7.1-mysql php7.1-opcache \
    php7.1-gd php7.1-curl php7.1-ldap php7.1-mysql php7.1-odbc php7.1-soap php7.1-xsl \
    php7.1-zip php7.1-intl php7.1-bcmath php7.1-cli php7.1-xdebug \
    imagemagick php7.1-imagick \
    rsync \
    build-essential python3 g++ python-is-python3 \
    unzip git-core ssh mysql-client nano vim less \
    msmtp msmtp-mta telnet sudo \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash \
  && . "$HOME/.nvm/nvm.sh" \
  && nvm install 22 \
  && rm -Rf /var/cache/apt/* \
  && a2enmod rewrite expires \
  && a2enmod headers \
  && phpenmod bcmath \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php composer-setup.php \
  && php -r "unlink('composer-setup.php');" \
  && mv composer.phar /usr/local/bin/composer \
  && echo 'export PATH="$PATH:/var/www/vendor/bin"' >> ~/.bashrc \
  && npm install -g grunt-cli \
  && npm install -g gulp-cli \
  && sed -i 's/\/var\/www\/html/\/var\/www\/web/g' /etc/apache2/sites-enabled/000-default.conf

RUN echo '#!/bin/bash' > /usr/bin/drush \
  && echo 'sudo -u www-data /var/www/vendor/bin/drush "$@"' >> /usr/bin/drush \
  && chmod +x /usr/bin/drush \
  && phpdismod xdebug \
  && mkdir -p /var/scripts \
  && cd /var/scripts \
  && mkdir -p /var/www/private \
  && chmod -Rf 777 /var/www/private

COPY config/php.ini /etc/php/apache2/php.ini
COPY config/apache2.conf /etc/apache2/apache2.conf
COPY config/mpm_prefork.conf /etc/apache2/mods-enabled/mpm_prefork.conf
COPY config/scripts /var/scripts

LABEL cron="drush cron" \
  update="sh /var/scripts/update.sh" \
  securityupdates="sh /var/scripts/securityupdates.sh" \
  restore="sh /var/scripts/restore.sh" \
  backup="sh /var/scripts/backup.sh" \
  test="sh /var/scripts/test.sh"

WORKDIR /var/www/web

CMD ["/var/scripts/startup.sh"]
