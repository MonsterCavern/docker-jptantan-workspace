#
#--------------------------------------------------------------------------
# Image Setup
#--------------------------------------------------------------------------
#
FROM phusion/baseimage:0.11

LABEL maintainer="Cosmo Weng <cosmos-s@hotmail.com.tw>"

ARG PHP_VERSION=7.4

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

# Add the "PHP 7" ppa
RUN apt-get install -y software-properties-common && \
  add-apt-repository -y ppa:ondrej/php

#
#--------------------------------------------------------------------------
# Software's Installation
#--------------------------------------------------------------------------
#

RUN echo 'DPkg::options { "--force-confdef"; };' >> /etc/apt/apt.conf

# Install "PHP Extentions", "libraries", "Software's"
RUN apt-get update && \
  apt-get upgrade -y && \
  apt-get install -y --allow-downgrades --allow-remove-essential \
  --allow-change-held-packages \
  php7.4-cli \
  php7.4-common \
  php7.4-curl \
  php7.4-intl \
  php7.4-json \
  php7.4-xml \
  php7.4-mbstring \
  php7.4-mysql \
  php7.4-pgsql \
  php7.4-sqlite \
  php7.4-sqlite3 \
  php7.4-zip \
  php7.4-bcmath \
  php7.4-memcached \
  php7.4-gd \
  php7.4-dev \
  pkg-config \
  libcurl4-openssl-dev \
  libedit-dev \
  libssl-dev \
  libxml2-dev \
  xz-utils \
  libsqlite3-dev \
  rsync \
  sqlite3 \
  git \
  curl \
  vim \
  nano \
  tree \
  postgresql-client \
  && apt-get clean

#####################################
# Composer:
#####################################

# Install composer and add its bin to the PATH.
RUN curl -s http://getcomposer.org/installer | php && \
  echo "export PATH=${PATH}:/var/www/vendor/bin" >> ~/.bashrc && \
  mv composer.phar /usr/local/bin/composer


#####################################
# OpenCC:
#####################################

ARG OPENCC_VERSION="ver.1.1.1"

RUN apt-get install -y cmake doxygen g++ make git python \
  && cd /tmp && git clone https://github.com/BYVoid/OpenCC.git && cd OpenCC \
  && git checkout -b ${OPENCC_VERSION} \
  && make \
  && make install \
  && apt-get purge -y make doxygen cmake

#####################################
# opencc4php:
#####################################

RUN apt-get install -y php7.4-dev \
  && cd /tmp && git clone https://github.com/NauxLiu/opencc4php.git && cd opencc4php \
  && phpize \
  && ./configure \
  && make && make install
# && apt-get purge -y php7.0-dev

COPY ./php_mods/opencc.ini /etc/php/${PHP_VERSION}/mods-available/opencc.ini

RUN phpenmod opencc

# Source the bash
RUN . ~/.bashrc