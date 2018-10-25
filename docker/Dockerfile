FROM library/postgres:10.5-alpine
COPY tds_fdw /tds_fdw
#COPY install/postgresql/init/* /docker-entrypoint-initdb.d/
RUN \
     echo 'http://dl-cdn.alpinelinux.org/alpine/v3.7/main' >> /etc/apk/repositories \
  && apk update \
  && apk add postgresql-dev postgresql-contrib freetds-dev=1.00.44-r0 make g++ \
  && cd /tds_fdw \
  && make clean \
  && make USE_PGXS=1 \
  && make USE_PGXS=1 install
