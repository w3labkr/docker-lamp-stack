FROM php:8.2-apache-bullseye

# Surpresses debconf complaints of trying to install apt packages interactively
# https://github.com/moby/moby/issues/4032#issuecomment-192327844

ARG DEBIAN_FRONTEND=noninteractive

# Update system, upgrade, and install all required packages in one layer; then clean apt cache
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends apt-utils cron nano wget dialog && \
    apt-get install -y --no-install-recommends libsqlite3-dev libsqlite3-0 default-mysql-client && \
    apt-get install -y --no-install-recommends libmagickwand-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    apt-get install -y --no-install-recommends zlib1g-dev libzip-dev libicu-dev && \
    apt-get install -y --no-install-recommends build-essential git curl libonig-dev && \
    apt-get install -y --no-install-recommends libcurl4 libcurl4-openssl-dev && \
    apt-get install -y --no-install-recommends zip unzip p7zip-full && \
    apt-get install -y --no-install-recommends openssl && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PECL extensions: xdebug, redis, imagick
RUN pecl install xdebug-3.2.2 && docker-php-ext-enable xdebug && \
    pecl install -o -f redis && rm -rf /tmp/pear && docker-php-ext-enable redis && \
    pecl install imagick && docker-php-ext-enable imagick

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql pdo_sqlite mysqli bcmath curl zip intl mbstring gettext calendar exif

# Configure and install GD extension with freetype and jpeg support
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg && \
    docker-php-ext-install gd

# Enable Apache modules: rewrite, headers, and ssl
RUN a2enmod rewrite headers ssl

# Enable default SSL site and create self-signed SSL certificates
RUN a2ensite default-ssl && \
    mkdir -p /etc/apache2/ssl /var/run/apache2/ && \
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=../ST=...../L=..../O=..../CN=..." \
        -keyout /etc/apache2/ssl/ssl.key \
        -out /etc/apache2/ssl/ssl.crt && \
    c_rehash /etc/apache2/ssl/

# Change www-data UID to 1000
RUN usermod -u 1000 www-data

# Clean up unnecessary build files
RUN rm -rf /usr/src/*
