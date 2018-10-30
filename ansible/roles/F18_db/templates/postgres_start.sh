#!/bin/bash

CONTAINER_NAME="{{ container }}"
IMAGE={{ docker_img }}
DATA_DIR="/srv/docker/$CONTAINER_NAME"

function start {
    echo "starting docker environment";

    #Postgres Server
    docker start $CONTAINER_NAME
    if [ $? -ne 0 ] > /dev/null 2>&1
    then
        docker run --restart unless-stopped \
            --publish {{ public_port }}:5432/tcp \
            --name $CONTAINER_NAME \
            --env 'PG_PASSWORD={{ pg_password }}' \
            --env 'REPLICATION_USER={{ pg_replication_user }}' \
            --env 'REPLICATION_PASS={{ pg_replication_password }}' \
            -v $DATA_DIR/var:/var/lib/postgresql \
            -v $DATA_DIR/docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
            -v $DATA_DIR/postgresql.conf:/etc/postgresql/postgresql.conf \
            -d \
            $IMAGE -c 'config_file=/etc/postgresql/postgresql.conf'
        docker logs $CONTAINER_NAME
    else
      stop;
      remove;
      start;
    fi
}

function stop {
    echo "stopping docker environment";
    docker exec -it  $CONTAINER_NAME service postgresql stop
    docker stop $CONTAINER_NAME
}

function remove {
    docker rm $CONTAINER_NAME
}

function restart {
    echo "restarting docker environment...";

    stop;
    start;

}

case "$1" in
    "start")
        start
        ;;
    "stop")
        stop
        ;;
    "rm")
        remove
        ;;
    "restart")
        restart
        ;;
    "upgrade")
        docker pull $IMAGE
        stop
        remove
        start
        ;;
    *)
        echo "usage: start | stop | restart | rm | upgrade"
        exit 1
        ;;
esac