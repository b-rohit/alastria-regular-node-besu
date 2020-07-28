#!/bin/bash

# Set the BESU_P2P_HOST environment variable to the public IP address of your node
HOST_IP=`dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null || curl -s --retry 2 icanhazip.com`
if [ -z "$HOST_IP" ]
then
  export BESU_P2P_HOST=0.0.0.0
  HOST_IP=127.0.0.1
else
  export BESU_P2P_HOST=$HOST_IP
fi

# Print the usage message
function printHelp() {
  echo "Usage: "
  echo "  node <mode>"
  echo "    <mode> - one of 'up', 'down', 'start', 'stop' or 'restart'"
  echo "      - 'up' - bring up the node with docker-compose up"
  echo "      - 'down' - clear the node with docker-compose down"
  echo "      - 'pause' - pause the node with docker-compose stop"
  echo "      - 'resume' - resume the node with docker-compose start"
  echo "      - 'restart' - restart the node"
}

function listEndpoints() {
  # displays services list with port mapping
  docker-compose ps
  echo "*************************************************************"
  echo "JSON-RPC HTTP service endpoint      : http://${HOST_IP}:8545"
  echo "Web block explorer address          : http://${HOST_IP}:3000/"
  echo "Prometheus address                  : http://${HOST_IP}:9090/graph"
}

function upNode() {
  echo "up"
  # create containers
  docker-compose up -d
  listEndpoints
}


function downNode() {
  echo "down"
  # remove containers
  docker-compose down -v
}

function pauseNode() {
  echo "pause"
  # stop containers
  docker-compose stop
}

function resumeNode() {
  echo "resume"
  # start containers
  docker-compose start
  listEndpoints
}

function restartNode() {
  echo "restart"
  # restart containers
  docker-compose stop
  sleep 20s
  docker-compose start
  listEndpoints
}

if [ "$1" = "-m" ]; then # supports old usage, muscle memory is powerful!
  shift
fi
MODE=$1
shift

# Determine the mode
if [ "$MODE" == "up" ]; then
  upNode
elif [ "$MODE" == "down" ]; then
  downNode
elif [ "$MODE" == "pause" ]; then
  pauseNode
elif [ "$MODE" == "resume" ]; then
  resumeNode
elif [ "$MODE" == "restart" ]; then
  restartNode
else
  printHelp
  exit 1
fi

exit 0
