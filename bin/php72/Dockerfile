#Quickfix - Basebox for PHP7.2 Library now uses Debian "10" Buster, superceeding #libcurl3, stretch is most compatible at this time whilst devs workout backport.
#https://github.com/docker-library/php/issues/865

FROM php:7.2-apache-stretch

#Surpresses debconf complaints of trying to install apt packages interactively
#https://github.com/moby/moby/issues/4032#issuecomment-192327844

ARG DEBIAN_FRONTEND=noninteractive

# Fix sources.list for Stretch
RUN printf "deb http://archive.debian.org/debian/ stretch main\n" > /etc/apt/sources.list && \
    printf "deb-src http://archive.debian.org/debian/ stretch main\n" >> /etc/apt/sources.list && \
    printf "deb http://archive.debian.org/debian-security stretch/updates main\n" >> /etc/apt/sources.list && \
    printf "deb-src http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# Update system, upgrade, and install all required packages in one layer; then clean apt cache
RUN apt-get update --fix-missing && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends build-essential git curl && \
    apt-get install -y --no-install-recommends libsqlite3-dev libsqlite3-0 mysql-client && \
    apt-get install -y --no-install-recommends zlib1g-dev libzip-dev && \
    apt-get install -y --no-install-recommends libicu-dev && \
    apt-get install -y --no-install-recommends libfreetype6-dev libjpeg62-turbo-dev libpng-dev && \
    apt-get install -y --no-install-recommends libcurl3 libcurl3-dev && \
    apt-get install -y --no-install-recommends apt-utils nano wget dialog && \
    apt-get install -y --no-install-recommends zip unzip p7zip-full && \
    apt-get install -y --no-install-recommends openssl && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install and enable xdebug
RUN pecl install xdebug-2.6.0 && docker-php-ext-enable xdebug

# Install and enable redis
RUN pecl install -o -f redis-5.3.7 && rm -rf /tmp/pear && docker-php-ext-enable redis

# Install and enable imagick
RUN pecl install imagick && docker-php-ext-enable imagick

# Install PHP extensions: pdo_mysql, pdo_sqlite, mysqli, curl, tokenizer, json, bcmath
RUN docker-php-ext-install pdo_mysql pdo_sqlite mysqli curl tokenizer json bcmath && \
    docker-php-ext-install zip && \
    docker-php-ext-install -j$(nproc) intl mbstring gettext calendar exif

# Configure and install GD with freetype and jpeg support
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd

# Enable Apache modules: rewrite and headers
RUN a2enmod rewrite headers

# Set up Apache SSL: create certificates and enable ssl site
RUN mkdir -p /etc/apache2/ssl/ /var/run/apache2/ && \
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=../ST=...../L=..../O=..../CN=..." \
        -keyout /etc/apache2/ssl/ssl.key \
        -out /etc/apache2/ssl/ssl.crt && \
    a2enmod ssl && a2ensite default-ssl && c_rehash /etc/apache2/ssl/

# Change www-data UID to 1000
RUN usermod -u 1000 www-data
