FROM php:7.1.20-apache

# Backup old sources.list and set new sources for stretch from archive.debian.org
RUN cp /etc/apt/sources.list /etc/apt/sources.list.old && \
    cat /dev/null > /etc/apt/sources.list && \
    printf "deb http://archive.debian.org/debian/ stretch main\n" > /etc/apt/sources.list && \
    printf "deb-src http://archive.debian.org/debian/ stretch main\n" >> /etc/apt/sources.list && \
    printf "deb http://archive.debian.org/debian-security stretch/updates main\n" >> /etc/apt/sources.list && \
    printf "deb-src http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

# Update system, upgrade, and install all required packages in one layer; then clean apt cache
RUN apt-get update --fix-missing && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends build-essential git curl && \
    apt-get install -y --no-install-recommends libmcrypt-dev libsqlite3-dev libsqlite3-0 mysql-client zlib1g-dev libzip-dev libicu-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libcurl3 libcurl3-dev && \
    apt-get install -y --no-install-recommends apt-utils nano wget dialog zip unzip p7zip-full && \
    rm -rf /var/lib/apt/lists/*

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions and PECL extensions in one RUN command
RUN docker-php-ext-install curl tokenizer json bcmath mcrypt pdo_mysql pdo_sqlite mysqli zip intl mbstring gettext && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install -j$(nproc) gd && \
    pecl install xdebug-2.5.5 && docker-php-ext-enable xdebug && \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini && \
    pecl install -o -f redis-5.3.7 && rm -rf /tmp/pear && docker-php-ext-enable redis

# Enable Apache modules: rewrite and headers
RUN a2enmod rewrite headers

# Set up Apache SSL: create certificate and enable SSL site
RUN mkdir -p /etc/apache2/ssl/ /var/run/apache2/ && \
    openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 \
        -subj "/C=../ST=...../L=..../O=..../CN=..." \
        -keyout /etc/apache2/ssl/ssl.key -out /etc/apache2/ssl/ssl.crt && \
    a2enmod ssl && a2ensite default-ssl && c_rehash /etc/apache2/ssl/

# Fix permissions for www-data
RUN usermod -u 1000 www-data

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
