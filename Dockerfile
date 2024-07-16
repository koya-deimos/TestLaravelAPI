FROM php:latest

RUN curl -sS https://getcomposer.org/installer | php -- \
     --install-dir=/usr/local/bin --filename=composer

ENV COMPOSER_ALLOW_SUPERUSER=1 
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN apt-get update && apt-get install -y zlib1g-dev \
    libzip-dev \
    unzip

RUN docker-php-ext-install pdo pdo_mysql sockets zip

RUN mkdir /app

ADD . /app

WORKDIR /app

RUN /bin/echo "checking composer version"

RUN composer --version
RUN composer install

CMD php artisan serve --host=0.0.0.0 --port=8000

EXPOSE 8000