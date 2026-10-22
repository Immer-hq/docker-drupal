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
  && apt-get -y install lsb-release ca-certificates curl \
  && curl -sSLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb \
  && dpkg -i /tmp/debsuryorg-archive-keyring.deb \
  && sh -c 'echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list' \
  && apt-get update \
  && curl -sL https://deb.nodesource.com/setup_18.x | bash - \
  && apt-get install -y --no-install-recommends \
    apache2 php8.5 libapache2-mod-php8.5 php8.5-memcached \
    php8.5-mbstring php8.5-xml php8.5-mysql \
    php8.5-gd php8.5-curl php8.5-ldap php8.5-mysql php8.5-odbc php8.5-soap php8.5-xsl \
    php8.5-zip php8.5-intl php8.5-bcmath php8.5-cli php8.5-xdebug \
    imagemagick php8.5-imagick \
    rsync nodejs \
    build-essential python3 g++ python-is-python3 \
    unzip git-core ssh mysql-client nano vim less \
    msmtp msmtp-mta telnet sudo \
  && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.8/install.sh | bash \
  && . "$HOME/.nvm/nvm.sh" \
  && nvm install 24 \
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
