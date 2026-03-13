#!/bin/bash

echo "FIXING INBOUND BGP ROUTE LEAK"
echo "--------------------------------------------------------"
if [ -f bird/as500.conf.bak ]; then
    cat bird/as500.conf.bak > bird/as500.conf
    echo "Reloading AS500 BIRD router..."
    docker exec as500 birdc -s /var/run/bird/bird.ctl configure
    echo "Network secured. The route leak has been plugged."
else
    echo "Backup file not found!"
fi