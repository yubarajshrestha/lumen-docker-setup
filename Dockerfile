FROM php:8.2-fpm-alpine3.17

# Install packages and remove default server definition
RUN apk update && apk add --no-cache \
    curl \
    nginx \
    supervisor \
    php-fpm

# # Add composer
RUN curl -sS https://getcomposer.org/installer | php && \
    chmod +x composer.phar && \
    mv composer.phar /usr/local/bin/composer

RUN composer --version

# Configure nginx
COPY container/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY container/fpm-pool.conf /etc/php/php-fpm.d/www.conf
COPY container/php.ini /etc/php/conf.d/custom.ini

# Configure supervisord and entrypoint
COPY container/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY container/entrypoint.sh /entrypoint.sh

# Add application
WORKDIR /var/www
COPY src/ /var/www/

# Install composer dependencies
RUN composer install --prefer-dist --no-dev

# Expose the port nginx is reachable on
EXPOSE 80

# Entrypoint script starts supervisord
# Use it for any processing during container launch
# Example generate .env file from a secrets manager
ENTRYPOINT ["/entrypoint.sh"]