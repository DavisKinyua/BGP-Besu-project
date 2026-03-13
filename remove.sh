#!/bin/bash -u

NO_LOCK_REQUIRED=false

. ./.env
. ./.common.sh

removeDockerImage(){
  if [[ ! -z `docker ps -a | grep $1` ]]; then
    docker image rm $1
  fi
}

echo "${bold}*************************************"
echo "BGP Besu Network Quickstart "
echo "*************************************${normal}"
echo "Stop and remove network..."

docker compose down -v
docker compose rm -sfv

if [ -f "docker-compose-deps.yml" ]; then
    echo "Stopping dependencies..."
    docker compose -f docker-compose-deps.yml down -v
    docker compose rm -sfv
fi
# pet shop dapp
if [[ ! -z `docker ps -a | grep quorum-dev-quickstart_pet_shop` ]]; then
  docker stop quorum-dev-quickstart_pet_shop
  docker rm quorum-dev-quickstart_pet_shop
  removeDockerImage quorum-dev-quickstart_pet_shop
fi

if grep -q 'kibana:' docker-compose.yml 2> /dev/null ; then
  docker image rm iob-besu-network_elasticsearch
  docker image rm iob-besu-network_logstash
  docker image rm iob-besu-network_filebeat
  docker image rm iob-besu-network_metricbeat
fi

rm ${LOCK_FILE}
echo "Lock file ${LOCK_FILE} removed"
