FROM ball6847/php-fpm:5.6
MAINTAINER Porawit Poboonma <ball6847@gmail.com>

ENV TERM=xterm-256color

RUN pecl install xdebug && \
    docker-php-ext-enable xdebug && \
    (curl -o- https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer)

