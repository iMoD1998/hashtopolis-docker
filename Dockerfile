FROM ghcr.io/linuxserver/baseimage-alpine-nginx:3.13


ARG BUILD_DATE
ARG HASHTOPOLIS_COMMIT_HASH

RUN echo "**** install packages ****" && \
    apk add --no-cache --upgrade \
    curl \
    libxml2 \
    php7-curl \
    php7-gd \
    php7-mcrypt \
    php7-pdo_mysql \
    php7-pear \
    sudo \
	tar \
	unzip && \
    echo "**** configure php and nginx for hashtopolis ****" && \
    sed -i \
	-e 's/;opcache.enable.*=.*/opcache.enable=1/g' \
	-e 's/;opcache.interned_strings_buffer.*=.*/opcache.interned_strings_buffer=8/g' \
	-e 's/;opcache.max_accelerated_files.*=.*/opcache.max_accelerated_files=10000/g' \
	-e 's/;opcache.memory_consumption.*=.*/opcache.memory_consumption=128/g' \
	-e 's/;opcache.save_comments.*=.*/opcache.save_comments=1/g' \
	-e 's/;opcache.revalidate_freq.*=.*/opcache.revalidate_freq=1/g' \
	-e 's/;always_populate_raw_post_data.*=.*/always_populate_raw_post_data=-1/g' \
	-e 's/memory_limit.*=.*128M/memory_limit=512M/g' \
	-e 's/max_execution_time.*=.*30/max_execution_time=120/g' \
	-e 's/upload_max_filesize.*=.*2M/upload_max_filesize=1024M/g' \
	-e 's/post_max_size.*=.*8M/post_max_size=1024M/g' \
		/etc/php7/php.ini && \
    sed -i \
	'/opcache.enable=1/a opcache.enable_cli=1' \
		/etc/php7/php.ini && \
    sed -i 's/;clear_env = no/clear_env = no/g' /etc/php7/php-fpm.d/www.conf && \
    echo "env[PATH] = /usr/local/bin:/usr/bin:/bin" >> /etc/php7/php-fpm.conf && \
    echo "**** set version tag ****" && \
    if [ -z ${HASHTOPOLIS_COMMIT_HASH+x} ]; then \
        HASHTOPOLIS_COMMIT_HASH=$(curl --no-progress-meter -X GET "https://api.github.com/repos/s3inlc/hashtopolis/git/refs/heads/master" \
        | awk '/sha/{print $4;exit}' FS='[""]' ); \
    fi && \
    echo "**** downloading and unpacking hashtopolis commit:${HASHTOPOLIS_COMMIT_HASH} ****" && \
    rm -rf /var/www/* && \
    curl --no-progress-meter -o /tmp/hashtopolis.tar.gz -L \
	"https://github.com/s3inlc/hashtopolis/archive/${HASHTOPOLIS_COMMIT_HASH}.tar.gz" && \
    mkdir -p "/tmp/hashtopolis" && \
    tar xvf "/tmp/hashtopolis.tar.gz" -C "/tmp/hashtopolis" --strip-components=1 && \
    mv "/tmp/hashtopolis/src/"* "/var/www" && \
    echo "**** removing .gitignore and .htaccess ****" && \
    find "/var/www/" -type f \( -name .htaccess -o -name .gitignore \) -print -exec rm {} \; && \
    echo "**** cleanup ****" && \
    rm -rf /tmp/* 

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80
EXPOSE 443

VOLUME ["/config", "/data"]