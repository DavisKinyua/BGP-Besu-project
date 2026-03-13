#!/bin/bash -u

# Licensed under the Apache License, Version 2.0 

NO_LOCK_REQUIRED=true

# Source env if it exists (for color codes etc), creating a dummy .env if missing to avoid errors
if [ -f ./.env ]; then . ./.env; fi
if [ -f ./.common.sh ]; then . ./.common.sh; fi

# Create log folders with user permissions so they won't conflict with container permissions
# We need folders for the nodes and the bird routers if mapped
mkdir -p logs/node1 logs/node2 logs/node3 logs/node4 logs/node5 logs/rpcnode
mkdir -p bird/socket middleware/data

# Create lock file
echo "docker-compose.yml" > ${LOCK_FILE:-".lock"}

echo "*************************************"
echo "BGP-Besu Network Quickstart"
echo "*************************************"
echo "Start network"
echo "--------------------"

echo "Starting network..."
# Ensure middleware is built
docker compose build --pull
docker compose up --detach

# List services and endpoints
./list.sh