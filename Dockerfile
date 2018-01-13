FROM php:apache
MAINTAINER Jason Cameron <jbkc85@gmail.com>

ENV MOODLE_VERSION=34 \
    MOODLE_GITHUB=git://git.moodle.org/moodle.git \
    MOODLE_DESTINATION=/var/www/html

# Download Essential Packages
RUN apt-get update \
    && apt-get install -y \
        gettext libcurl4-openssl-dev libpq-dev  libxslt-dev \
        libxml2-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libmemcached-dev \
        zlib1g-dev unixodbc-dev libpng-dev libjpeg-dev libpq-dev \
        graphviz aspell aspell-pt-br libpspell-dev git-core libcurl4-openssl-dev \
        unzip ghostscript locales apt-transport-https \
        libaio1 libcurl3 libgss3 libpq5 libmemcached11 \
        libmemcachedutil2 libldap-2.4-2 libxml2 libxslt1.1 unixodbc libmcrypt-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-install -j$(nproc) intl mysqli pdo pdo_mysql xmlrpc xsl curl zip opcache soap \
    && pecl install memcached redis apcu igbinary \
    && docker-php-ext-enable opcache memcached redis apcu igbinary \
    && echo 'apc.enable_cli = On' >> /usr/local/etc/php/conf.d/docker-php-ext-apcu.ini \
    && apt-get remove --purge -y gettext libcurl4-openssl-dev libpq-dev libmysqlclient-dev libldap2-dev \
        libxslt-dev libxml2-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libmemcached-dev \
        zlib1g-dev libpng12-dev unixodbc-dev \
    && apt-get autoremove -y \
    && pecl clear-cache \
    && apt-get clean && rm -rf /var/lib/apt/lists* /tmp/* /var/tmp/*

# Copy in and make default content areas
RUN git clone -b MOODLE_${MOODLE_VERSION}_STABLE --depth 1 ${MOODLE_GITHUB} ${MOODLE_DESTINATION}

RUN mkdir -p /moodle/data && \
    chown -R www-data:www-data /moodle && \
    chmod 2775 /moodle && \
    ln -sf /moodle/conf/config.php ${MOODLE_DESTINATION}/config.php

# Enable mod_rewrite
RUN a2enmod rewrite
