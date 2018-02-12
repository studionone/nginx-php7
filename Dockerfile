FROM ubuntu:16.04

MAINTAINER Greg Beaven <greg@studionone.com.au>

# Install PHP7
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y language-pack-en-base && \
    export LC_ALL=en_AU.UTF-8 && \
    export LANG=en_AU.UTF-8 && \
    locale-gen en_AU.UTF-8 && \
    apt-get install -y software-properties-common \
        python-software-properties \
        build-essential && \
    add-apt-repository -y ppa:ondrej/php

# Needed for add-apt-repository to work due to UTF-8
RUN locale-gen en_AU.UTF-8
ENV LANG C.UTF-8

RUN apt-get update && \
    apt-get install -y --force-yes supervisor \ 
    nginx \
    php7.1-fpm \
    php7.1-common \
    php7.1-gd \
    php7.1-json \
    php7.1-zip \
    php7.1-curl \
    php7.1-xml \
    php7.1-intl \
    php7.1-mbstring \
    wget \
    curl \
    zip \
    unzip

RUN service php7.1-fpm stop && \
    service nginx stop && \
    service supervisor stop

ADD conf/supervisord.conf /etc/supervisord.conf
ADD conf/nginx/sites-enabled/default /etc/nginx/sites-enabled/default
ADD conf/www.conf /etc/php/7.1/fpm/pool.d/www.conf

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
