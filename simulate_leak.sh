#!/bin/bash

echo "SIMULATING BGP ROUTE LEAK (AS500 Leaking)"
echo "--------------------------------------------------------"
echo "Topology Context: AS600 is the Upstream Provider for AS500."
echo "AS500 will incorrectly act as a transit router and leak routes both ways!"

# Back up the clean AS500 configuration
cp bird/as500.conf bird/as500.conf.bak


echo "Injecting 'export all;' into AS500..."
sed 's/export filter attack_route;/export all; # FATAL ROUTE LEAK/g' bird/as500.conf > temp_leak.conf
cat temp_leak.conf > bird/as500.conf
rm temp_leak.conf


echo "Reloading AS500 BIRD router..."
docker exec as500 birdc -s /var/run/bird/bird.ctl configure
echo "Waiting 3 seconds for BGP convergence..."
sleep 3


echo "--------------------------------------------------------"
echo "VERIFYING UNPROTECTED AS600:"
docker exec as600 birdc -s /var/run/bird/bird.ctl show route 10.4.0.0/24
echo "AS600 blindly accepted the leak! It is now sending AS400's traffic through AS500!"


echo "--------------------------------------------------------"
echo "VERIFYING PROTECTED AS400:"
echo "Check Uni-Guard logs (docker logs -f uni-guard)."
echo "It should catch the leaked path [500, 600] and block it as an ASPA Violation!"