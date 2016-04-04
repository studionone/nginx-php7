FROM ubuntu:14.04.1

MAINTAINER Greg Beaven <greg@studionone.com.au>

# Install PHP7
RUN apt-get install -y language-pack-en-base && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --force-yes supervisor \ 
    nginx \
    php7.0 \
    php7.0-cli \
    php7.0-fpm \
    php7.0-gd \
    php7.0-json \
    php7.0-zip \
    wget

RUN service php7.0-fpm stop && \
    service nginx stop && \
    service supervisor stop

ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/nginx/sites-enabled/default /etc/nginx/sites-enabled/default
ADD conf/www.conf /etc/php/7.0/fpm/pool.d/www.conf

COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN mkdir -p /run/php /var/run/php
RUN mkdir -p /var/www
ENV TERM xterm-256color

RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN sed -i 's/sendfile on/sendfile off/' /etc/nginx/nginx.conf
RUN sed -i 's/user www-data/user root root/' /etc/nginx/nginx.conf

# Install Composer
RUN wget -O /tmp/composer.phar https://getcomposer.org/composer.phar && cp /tmp/composer.phar /usr/local/bin/composer && chmod +x /usr/local/bin/composer

#add default page for testing nginx
ADD var/www /var/www

EXPOSE 80

ENTRYPOINT ["/start.sh"]
