FROM php:7.2-alpine

ARG BUILD_DATE
ARG VCS_REF

ENV COMPOSER_ALLOW_SUPERUSER 1

LABEL Maintainer="esseak <esseak@gmail.com>" \
      Description="Lightweight php 7.2 container based on alpine with Composer installed and swoole pecl installed." \
      org.label-schema.name="esseak/php72-swoole" \
      org.label-schema.description="Lightweight php 7.2 container based on alpine with Composer installed and swoole pecl installed." \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.version="1.2.3" \
      org.label-schema.vcs-url="https://github.com/esseak/php72-swoole.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.docker.schema-version="1.0"

RUN set -ex \
      && cp /etc/apk/repositories /etc/apk/repositories.bak \
      && echo "http://mirrors.aliyun.com/alpine/v3.8/main/" > /etc/apk/repositories \
  	&& apk update \
    && apk add --no-cache git mysql-client curl openssh-client icu libpng freetype libjpeg-turbo postgresql-dev libffi-dev \
    && apk add --no-cache --virtual build-dependencies icu-dev libxml2-dev freetype-dev libpng-dev libjpeg-turbo-dev g++ make autoconf \
    && docker-php-source extract \
    && pecl install swoole redis mongodb \
    && docker-php-ext-enable redis swoole mongodb \
    && docker-php-source delete \
    && docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) pgsql pdo_mysql pdo_pgsql intl zip gd \
    && curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && cd  / && rm -fr /src \
    && apk del build-dependencies \
    && rm -rf /tmp/* 

USER www-data

WORKDIR /var/www
CMD ["php", "-a"]
