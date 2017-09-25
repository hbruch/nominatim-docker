FROM ubuntu:16.04

# Defines the concurrency of the installation
ENV THREADS 6

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8

# Install locales before installing postgresql
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
			python python-pip python-setuptools libboost-python1.58 libboost-python-dev \
                        php-intl git curl nano ca-certificates sudo \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /tmp/* /var/tmp/*

RUN pip install osmium

WORKDIR /app

# Configure postgres
RUN echo "host all  all    0.0.0.0/0  trust" >> /etc/postgresql/9.5/main/pg_hba.conf && \
    echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf


RUN useradd -d /srv/nominatim -s /bin/bash -m nominatim

ENV USERNAME nominatim
ENV USERHOME /srv/nominatim

WORKDIR /srv/nominatim

# Nominatim install
ENV NOMINATIM_VERSION v3.0.1
RUN git clone --recursive git://github.com/openstreetmap/Nominatim.git ./Nominatim \
  && cd ./Nominatim \
  && git checkout $NOMINATIM_VERSION \
  && git submodule update --recursive --init \
  && curl http://www.nominatim.org/data/country_grid.sql.gz > data/country_osm_grid.sql.gz \
  && mkdir build \
  && cd build \
  && cmake .. \
  && make -j $THREADS \
  && make install \
  && chown -R nominatim:www-data $USERHOME \
  && chmod a+x $USERHOME


# Apache configure
#COPY nominatim.conf /etc/apache2/sites-enabled/000-default.conf
COPY apache-nominatim.conf /etc/apache2/conf-available/nominatim.conf
RUN a2enconf nominatim

COPY firstrun.sh start.sh postgresql.conf /app/
RUN cat /app/postgresql.conf >> /etc/postgresql/9.5/main/postgresql.conf

COPY local.php /srv/nominatim/Nominatim/settings/local.php

# Pipe errors to stdout, access them with `docker logs $CONTAINER_ID`
RUN rm /var/log/apache2/*.log \
  && ln -s /dev/stdout /var/log/apache2/access.log \
  && ln -s /dev/stderr /var/log/apache2/error.log

EXPOSE 5432
EXPOSE 8080

VOLUME /var/lib/postgresql

#USER nominatim

CMD /app/start.sh
