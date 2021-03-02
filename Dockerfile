FROM php:apache

ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

RUN	export DEBIAN_FRONTEND=noninteractive && \
	apt update && \
	apt -y upgrade && \
	apt -y install curl \
                   git \
                   pwgen \
                   libcurl4-openssl-dev \
                   libmcrypt-dev \
                   libpng-dev \
                   libxml2-dev \
                   zlib1g-dev && \
    pecl install mcrypt-1.0.4 && \
    docker-php-ext-install -j$(nproc) opcache pdo_mysql mysqli gd && \
    docker-php-ext-enable mcrypt

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/^memory_limit.*$/memory_limit=256M/' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/^post_max_size.*$/post_max_size=100M/' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/^upload_max_filesize.*$/upload_max_filesize=100M/' "$PHP_INI_DIR/php.ini" && \
    sed -i 's/^KeepAliveTimeout.*$/KeepAliveTimeout 10/' "$APACHE_CONFDIR/apache2.conf"

RUN cd /var/www && \
    rm * -rf && \
    git clone https://github.com/s3inlc/hashtopolis.git && \
    echo "$APACHE_RUN_USER:$APACHE_RUN_GROUP" && \
    chown -R $APACHE_RUN_USER:$APACHE_RUN_GROUP /var/www/ && \
    ln -sf /dev/stdout /var/log/apache2/access.log && \
	ln -sf /dev/sterr /var/log/apache2/error.log && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

COPY 000-default.conf $APACHE_CONFDIR/sites-enabled/

EXPOSE 80
EXPOSE 443
