#!/usr/bin/env bash
#

function help_menu() {
  cat << EOF
  usage: jelly.sh COMMAND
  COMMAND can be:
    up - Start the Service.
    down - Stop and Remove.
EOF
}

function up() {
  podman pod create --name browserq --publish 8098:8098  --publish 8099:80

  podman run -d -it \
    --name redis \
    --pod browserq \
    -e REQUIREAUTH=no \
    -v ./redisdata:/data \
    docker.io/redis:latest bash -c "redis-server --appendonly yes" 

  podman run -d -it \
     --name mem \
     --pod browserq \
     docker.io/memcached:latest

  podman run -d -it \
     --name server \
     --pod browserq \
     -v ./:/app \
     -w /app \
     docker.io/node:latest bash -c "cd /app && node server/js/main.js"
}

function down() {
  podman pod stop browserq 
  podman pod rm browserq 
}

operation=$1

case $operation in
  up)
    up
    ;;
  down)
    down
    ;;
  *)
    help_menu
    ;;
esac
