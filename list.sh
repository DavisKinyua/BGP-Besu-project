#!/bin/bash -eu

# Copyright 2018 ConsenSys AG.

NO_LOCK_REQUIRED=false

if [ -f ./.env ]; then . ./.env; fi
if [ -f ./.common.sh ]; then . ./.common.sh; fi

HOST=${DOCKER_PORT_2375_TCP_ADDR:-"localhost"}

echo "*************************************"
echo "BGP-Besu Network Status"
echo "*************************************"

# --- JSON-RPC ---
if [ ! -z `docker compose ps -q rpcnode 2> /dev/null` ]; then
  echo "JSON-RPC HTTP Service                : http://${HOST}:8545"
  echo "JSON-RPC WebSocket Service           : ws://${HOST}:8546"
fi

# --- Explorer ---
if [ ! -z `docker compose ps -q explorer 2> /dev/null` ]; then
  echo "Quorum Explorer                      : http://${HOST}:25000/"
fi

# --- Monitoring ---
if [ ! -z `docker compose ps -q prometheus 2> /dev/null` ]; then
  echo "Prometheus                           : http://${HOST}:9090/graph"
fi
if [ ! -z `docker compose ps -q grafana 2> /dev/null` ]; then
  echo "Grafana                              : http://${HOST}:3000/"
fi

# --- Middleware ---
echo "----------------------------------"
echo "Middleware Status:"
if [ ! -z `docker compose ps -q uni-guard 2> /dev/null` ]; then
  echo "Uni-Guard (Security Bot)             : RUNNING"
else
  echo "Uni-Guard (Security Bot)             : STOPPED"
fi

echo "----------------------------------"
echo "For more info, check the logs:"
echo "  docker compose logs -f uni-guard"
echo "  docker compose logs -f rpcnode"