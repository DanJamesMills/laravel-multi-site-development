# Use the official PHP 8.3 FPM Alpine image (smaller footprint)
FROM php:8.3-fpm-alpine

# Match container user to host user for proper file permissions on Linux
ARG UID=1000
RUN apk add --no-cache shadow && \
    usermod -u ${UID} www-data && \
    apk del shadow

WORKDIR /var/www/html

# Install build dependencies (removed after compilation) and runtime dependencies
RUN apk add --no-cache --virtual .build-deps \
        $PHPIZE_DEPS \
        postgresql-dev \
        libzip-dev \
        oniguruma-dev \
        libxml2-dev \
        libpng-dev \
        libjpeg-turbo-dev \
        freetype-dev \
        imagemagick-dev \
        linux-headers \
    && apk add --no-cache \
        curl \
        unzip \
        git \
        libpq \
        libzip \
        oniguruma \
        libxml2 \
        libpng \
        libjpeg-turbo \
        freetype \
        imagemagick \
        imagemagick-libs \
        nodejs \
        npm \
        jpegoptim \
        optipng \
        pngquant \
        gifsicle \
        libwebp-tools \
        libavif-apps \
        icu-libs \
        icu-dev \
    # Configure and install PHP extensions
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        pdo \
        pdo_mysql \
        mysqli \
        pdo_pgsql \
        mbstring \
        zip \
        exif \
        gd \
        bcmath \
        intl \
        pcntl \
        opcache \
    # Install PECL extensions
    && pecl install redis imagick \
    && docker-php-ext-enable redis imagick \
    # Remove build dependencies
    && apk del .build-deps \
    && rm -rf /tmp/* /var/cache/apk/*

# Install npm global packages
RUN npm install -g svgo && npm cache clean --force

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

# Copy PHP configuration
COPY php.ini /usr/local/etc/php/conf.d/dev-server.ini

EXPOSE 9000

CMD ["php-fpm"]
