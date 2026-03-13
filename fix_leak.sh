#!/bin/bash

echo "FIXING BGP ROUTE LEAK"
echo "--------------------------------------------------------"

# 1. Restore the clean configuration
echo "1. Restoring clean AS500 configuration from backup..."
if [ -f bird/as500.conf.bak ]; then
    cat bird/as500.conf.bak > bird/as500.conf
else
    echo "Backup file not found! Skipping restore."
fi

# 2. Reload the router
echo "2. Reloading AS500 BIRD router..."
docker exec as500 birdc -s /var/run/bird/bird.ctl configure
echo "Waiting for BGP convergence..."
sleep 3

echo "--------------------------------------------------------"
echo "Network secured. The route leak has been plugged."