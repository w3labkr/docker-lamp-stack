FROM php:7.4-apache-buster

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844

ARG DEBIAN_FRONTEND=noninteractive

# Update system, upgrade, and install all required packages in one layer; then clean apt cache
RUN apt-get update --fix-missing && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils nano wget dialog && \
    apt-get install -y --no-install-recommends libsqlite3-dev libsqlite3-0 default-mysql-client && \
    apt-get install -y --no-install-recommends zlib1g-dev libzip-dev libicu-dev && \
    apt-get install -y --no-install-recommends build-essential git curl libonig-dev && \
    apt-get install -y --no-install-recommends libcurl4 libcurl4-openssl-dev && \
    apt-get install -y --no-install-recommends zip unzip p7zip-full && \
    apt-get install -y --no-install-recommends openssl && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install and enable xdebug
RUN pecl install xdebug-3.2.0 && docker-php-ext-enable xdebug

# Install and enable redis extension
RUN pecl install -o -f redis-5.3.7 && rm -rf /tmp/pear && docker-php-ext-enable redis

# Install libmagickwand-dev, then install and enable imagick via PECL
RUN apt-get update && \
    apt-get install -y --no-install-recommends libmagickwand-dev && \
    rm -rf /var/lib/apt/lists/* && \
    pecl install imagick && docker-php-ext-enable imagick

# Install PHP extensions (pdo_mysql, pdo_sqlite, mysqli, curl, tokenizer, json, bcmath, zip, intl, mbstring, gettext, calendar, exif)
RUN docker-php-ext-install pdo_mysql pdo_sqlite mysqli curl tokenizer json bcmath zip && \
    docker-php-ext-install -j$(nproc) intl mbstring gettext calendar exif

# Install and configure GD with freetype and jpeg support
RUN apt-get update && \
    apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd

# Enable Apache modules: rewrite and headers
RUN a2enmod rewrite headers

# Enable Apache SSL: create SSL directory, generate self-signed certificate, enable ssl site, and rehash certificates
RUN mkdir -p /etc/apache2/ssl/ && \
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj "/C=../ST=...../L=..../O=..../CN=..." -keyout /etc/apache2/ssl/ssl.key -out /etc/apache2/ssl/ssl.crt && \
    mkdir -p /var/run/apache2/ && \
    a2enmod ssl && a2ensite default-ssl && c_rehash /etc/apache2/ssl/

# Change www-data UID to 1000
RUN usermod -u 1000 www-data

# Cleanup build files
RUN rm -rf /usr/src/*

# Copy the entrypoint script and grant execution permission
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set the custom entrypoint to run cron and Apache
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]