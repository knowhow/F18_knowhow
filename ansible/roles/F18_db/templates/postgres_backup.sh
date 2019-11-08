#!/bin/bash

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin


CONTAINER_NAME="{{ container }}.backup"
IMAGE={{ docker_img }}
DATA_DIR="{{backup_data_dir}}"
DATETIME=$(date +%Y%m%d%H%M%S)

docker run --name $CONTAINER_NAME -it --rm \
  --link {{ container }}:master \
  --env 'REPLICATION_MODE=backup' --env 'REPLICATION_SSLMODE=prefer' \
  --env 'REPLICATION_HOST=master' --env 'REPLICATION_PORT=5432'  \
  --env 'REPLICATION_USER={{ pg_replication_user }}' --env 'pg_replication_password={{ pg_replication_password }}' \
  --volume $DATA_DIR/postgresql.$DATETIME:/var/lib/postgresql \
  $IMAGE

tar cfvz $DATA_DIR/postgresql.$DATETIME.tar.gz  $DATA_DIR/postgresql.$DATETIME && rm -rf $DATA_DIR/postgresql.$DATETIME
