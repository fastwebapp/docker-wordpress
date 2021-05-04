FROM wordpress:latest

RUN apt-get update \
  && apt-get install -y \
    default-mysql-client \
    unzip \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean

# WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
  && chmod +x wp-cli.phar \
  && mv wp-cli.phar /usr/local/bin/wp \
  && mkdir -p /var/www/.wp-cli/cache \
  && chown -R www-data /var/www/.wp-cli

# FIXME: https://github.com/wp-cli/wp-cli/issues/5494
RUN wp cli update --nightly --yes

# MailHog
RUN curl -sSLO https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 \
  && chmod +x mhsendmail_linux_amd64 \
  && mv mhsendmail_linux_amd64 /usr/local/bin/mhsendmail \
  && echo 'sendmail_path = "/usr/local/bin/mhsendmail --smtp-addr=mailhog:1025"' > /usr/local/etc/php/conf.d/sendmail.ini

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN mkdir /var/www/.composer/ \
  && chown -R www-data /var/www/.composer \
