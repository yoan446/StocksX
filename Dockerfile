FROM php:8.3-cli

# Autoriser Composer à s'exécuter en root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Installer les dépendances système
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libzip-dev \
    libpq-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libicu-dev \
    libssl-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd intl zip \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copier Composer depuis l'image officielle
COPY --from=composer:2.7 /usr/bin/composer /usr/bin/composer

# Définir le dossier de travail
WORKDIR /var/www

# Copier le projet Laravel
COPY . .

# Créer les répertoires nécessaires avec les bonnes permissions
RUN mkdir -p storage/framework/{cache,sessions,views} bootstrap/cache \
    && chown -R www-data:www-data /var/www \
    && chmod -R 775 storage bootstrap/cache

# Installer les dépendances PHP sans exécuter les scripts
RUN composer install --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# Exposer le port 8000
EXPOSE 8000