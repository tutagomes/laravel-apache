FROM php:7.2-apache-stretch

WORKDIR /var/www/html

# Banco temporário para criar link de storage
ENV DB_DATABASE /var/www/html/database.sqlite
ENV DB_CONNECTION sqlite

# Adiciona banco temporário
RUN touch database.sqlite

# Configurando drivers necessários
RUN apt-get update
RUN apt-get install libgmp-dev -y
RUN docker-php-ext-configure gmp 
RUN docker-php-ext-install gmp
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo_mysql
RUN pecl install redis && docker-php-ext-enable redis

# Removendo pasta caso exista
RUN rm -rf /var/www/html/public/storage || true
# Recriando link
RUN php artisan storage:link

#change uid and gid of apache to docker user uid/gid
RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

#change the web_root to laravel /var/www/html/public folder
RUN sed -i -e "s/html/html\/public/g" /etc/apache2/sites-enabled/000-default.conf

# enable apache module rewrite
RUN a2enmod rewrite

#change ownership of our applications
RUN chown -R www-data:www-data /var/www/html