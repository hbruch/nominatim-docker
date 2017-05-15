FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

RUN apt-get update -qq \
    && apt-get -y install locales \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

RUN locale-gen en_US.UTF-8
RUN update-locale LANG=en_US.UTF-8

RUN apt-get update -qq \
    && apt-get install -y -o APT::Install-Recommends="false" -o APT::Install-Suggests="false" -y \
      build-essential cmake g++ libboost-dev libboost-system-dev \
      libboost-filesystem-dev libexpat1-dev zlib1g-dev libxml2-dev\
      libbz2-dev libpq-dev libgeos-dev libgeos++-dev libproj-dev \
      postgresql-server-dev-9.5 postgresql-9.5-postgis-2.2 postgresql-contrib-9.5 \
      apache2 php php-pgsql libapache2-mod-php php-pear php-db \
      git sudo \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*


RUN apt-get update && apt-get -y install ca-certificates curl
WORKDIR /app

# Configure postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf

# Defines the concurrency of the installation and import ToDo: move to Readme
ENV THREADS 6

# Nominatim install
# Nominatim master from 2017-05-15
# freezing version to have reproducible results
ENV NOMINATIM_VERSION 6830b12
RUN git clone --recursive git://github.com/openstreetmap/Nominatim.git ./src \
  && cd ./src && git checkout $NOMINATIM_VERSION && git submodule update --recursive --init \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make -j $THREADS \
  && make install

# Nominatim create site
COPY local.php ./src/build/settings/local.php
RUN rm -rf /var/www/html \
  && ln -s /app/src/build/website /var/www/html \
  && ln -s /app/src/build/settings /var/www/

# Apache configure
COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf

COPY firstrun.sh start.sh postgresql.conf /app/
RUN cat /app/postgresql.conf >> /etc/postgresql/9.5/main/postgresql.conf

# Pipe errors to stdout, access them with `docker logs $CONTAINER_ID`
RUN rm /var/log/apache2/*.log \
  && ln -s /dev/stdout /var/log/apache2/access.log \
  && ln -s /dev/stderr /var/log/apache2/error.log

EXPOSE 5432
EXPOSE 8080


CMD /app/start.sh
