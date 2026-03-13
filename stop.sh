#!/bin/bash -u

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

echo "${bold}*************************************"
echo "BGP Besu Network Quickstart "
echo "*************************************${normal}"
echo "Stopping network"
echo "----------------------------------"


docker compose stop

if [ -f "docker-compose-deps.yml" ]; then
    echo "Stopping dependencies..."
    docker compose -f docker-compose-deps.yml stop
fi

