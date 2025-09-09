FROM php:5.6-apache

# Set environment variables for optimization
ENV DEBIAN_FRONTEND=noninteractive \
    MAKEFLAGS="-j$(nproc)" \
    PHP_MEMORY_LIMIT=256M \
    PHP_MAX_EXECUTION_TIME=300 \
    PHP_UPLOAD_MAX_FILESIZE=50M \
    PHP_POST_MAX_SIZE=50M

# Backup old sources.list and set new sources for jessie from archive.debian.org
RUN cp /etc/apt/sources.list /etc/apt/sources.list.old && \
    cat /dev/null > /etc/apt/sources.list && \
    printf "deb http://archive.debian.org/debian/ jessie main\n" > /etc/apt/sources.list && \
    printf "deb-src http://archive.debian.org/debian/ jessie main\n" >> /etc/apt/sources.list && \
    printf "deb http://archive.debian.org/debian-security jessie/updates main\n" >> /etc/apt/sources.list && \
    printf "deb-src http://archive.debian.org/debian-security jessie/updates main" >> /etc/apt/sources.list

# Install only essential system dependencies to avoid conflicts
RUN apt-get update --fix-missing && \
    apt-get install -y --no-install-recommends --allow-unauthenticated \
        build-essential \
        git \
        curl \
        wget \
        nano \
        zip \
        unzip \
        p7zip-full \
        pkg-config \
        cron \
        libicu-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Composer in a separate layer for better caching
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install PHP extensions without GD first (most stable)
RUN docker-php-ext-install -j$(nproc) \
        tokenizer \
        json \
        bcmath \
        pdo_mysql \
        mysqli \
        intl \
        mbstring \
        gettext

# Install PECL extensions
RUN pecl install xdebug-2.4.1 && \
    pecl install redis-2.2.8 && \
    docker-php-ext-enable xdebug redis && \
    echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    rm -rf /tmp/pear

# Create PHP configuration with optimized settings
RUN { \
        echo 'memory_limit = ${PHP_MEMORY_LIMIT}'; \
        echo 'max_execution_time = ${PHP_MAX_EXECUTION_TIME}'; \
        echo 'upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}'; \
        echo 'post_max_size = ${PHP_POST_MAX_SIZE}'; \
        echo 'date.timezone = UTC'; \
        echo 'expose_php = Off'; \
        echo 'display_errors = Off'; \
        echo 'log_errors = On'; \
        echo 'error_log = /var/log/apache2/php_errors.log'; \
    } > /usr/local/etc/php/conf.d/docker-php-custom.ini

# Enable Apache modules
RUN a2enmod rewrite headers ssl

# Set up Apache SSL with improved certificate generation
RUN mkdir -p /etc/apache2/ssl/ /var/run/apache2/ && \
    openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 \
        -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost" \
        -keyout /etc/apache2/ssl/ssl.key \
        -out /etc/apache2/ssl/ssl.crt && \
    a2dissite default-ssl && \
    c_rehash /etc/apache2/ssl/

# Fix permissions for www-data
RUN usermod -u 1000 www-data

# Copy the entrypoint script and set permissions
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

# Expose ports
EXPOSE 80 443

# Set working directory
WORKDIR /var/www/html

# Set the custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
