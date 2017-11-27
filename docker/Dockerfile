FROM php:5.6.30-apache

VOLUME ["/var/www"]

RUN apt-get update \
  && apt-get install -y apt-utils \
  && apt-get install -y libfreetype6-dev \
  && apt-get install -y libjpeg62-turbo-dev \
  && apt-get install -y libcurl4-gnutls-dev \
  && apt-get install -y libxml2-dev \
  && apt-get install -y freetds-dev \
  && apt-get install -y git \
  && apt-get install -y curl \
  && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install gd \
  && docker-php-ext-install soap \
  && apt-get install -y libpq-dev \
  && docker-php-ext-install calendar \
  && docker-php-ext-configure pgsql --with-pgsql=/usr/local/pgsql \
  && docker-php-ext-configure pdo_pgsql --with-pgsql \
  && docker-php-ext-install pgsql pdo_pgsql \
  && curl -sS https://getcomposer.org/installer | php \
  && mv composer.phar /usr/local/bin/ \
  && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

WORKDIR /var/www/

EXPOSE 80
EXPOSE 8888
EXPOSE 9000

COPY . /tmp/src
RUN chmod +x -R /tmp/src/

COPY ./actions/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

CMD /tmp/src/actions/start.sh
