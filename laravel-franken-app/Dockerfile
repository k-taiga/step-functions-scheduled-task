FROM dunglas/frankenphp:latest-php8.3

# 必要なPHP拡張機能のインストール
RUN install-php-extensions \
    pdo_mysql \
    mbstring \
    exif \
    pcntl \
    bcmath \
    gd \
    intl \
    zip \
    opcache

# Composerのインストール
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 作業ディレクトリの設定
WORKDIR /app

# Laravelアプリケーションのコピー
COPY . .

# 依存関係のインストール
RUN composer install --no-interaction --no-dev --optimize-autoloader

# 権限の設定
RUN chown -R www-data:www-data /app \
    && chmod -R 755 /app/storage \
    && chmod -R 755 /app/bootstrap/cache

# Caddyfileの設定
RUN echo "{\n\
    frankenphp\n\
    order php_server before file_server\n\
}\n\
\n\
:8000 {\n\
    root * /app/public\n\
    php_server\n\
    file_server\n\
    encode gzip\n\
}" > /etc/caddy/Caddyfile

EXPOSE 8000

# FrankenPHPの起動
CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]
