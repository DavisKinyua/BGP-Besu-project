#!/bin/bash -u

# Copyright 2018 ConsenSys AG.

NO_LOCK_REQUIRED=false

if [ -f ./.env ]; then . ./.env; fi
if [ -f ./.common.sh ]; then . ./.common.sh; fi

echo "*************************************"
echo "BGP-Besu Network Quickstart"
echo "*************************************"
echo "Resuming network..."
echo "----------------------------------"

docker compose start