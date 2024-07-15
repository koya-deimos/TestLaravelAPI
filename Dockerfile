# Stage 1: Build stage
FROM composer:latest AS build

# Set working directory
WORKDIR /app

# Copy composer.json and composer.lock
COPY composer.json composer.lock ./

# Install PHP dependencies
RUN composer install --no-dev --no-scripts --prefer-dist --no-progress --no-interaction

# Stage 2: Production stage
FROM php:8.1-fpm-alpine

# Set working directory
WORKDIR /var/www

# Install system dependencies
# Install system dependencies
RUN apk update && apk add --no-cache \
    nginx \
    libpng-dev \
    libjpeg-turbo-dev \
    libfreetype6-dev \
    bash \
    autoconf \
    g++ \
    make \
    curl \
    git \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring exif pcntl bcmath

# Install PHP extensions
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring exif pcntl bcmath

# Copy nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy application code from build stage
COPY --from=build /app /var/www

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Change current user to www
USER www-data

# Expose port 80 for Nginx
EXPOSE 80

# Start PHP-FPM and Nginx
CMD ["sh", "-c", "php-fpm & nginx -g 'daemon off;'"]
