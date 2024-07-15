FROM php:8.2-fpm

ARG user
ARG uid

RUN apt update && apt install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev
RUN apt clean && rm -rf /var/lib/apt/lists/*
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

WORKDIR /var/www
# Set working directory

# Install system dependencies
# Install system dependencies
# RUN apt-get update && apt-get install -y \
#     nginx \
#     libpng-dev \
#     libjpeg-turbo-dev \
#     libfreetype6-dev \
#     bash \
#     autoconf \
#     g++ \
#     make \
#     curl \
#     git \
#     unzip \
#     && docker-php-ext-configure gd --with-freetype --with-jpeg \
#     && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring exif pcntl bcmath

# # Install PHP extensions
# RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
#     && docker-php-ext-install -j$(nproc) gd pdo_mysql mbstring exif pcntl bcmath

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
