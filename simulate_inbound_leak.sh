#!/bin/bash

echo "SIMULATING INBOUND BGP ROUTE LEAK (AS500 Leaking)"
echo "--------------------------------------------------------"

# 1. Back up the clean configuration for AS500
echo "1. Backing up clean AS500 configuration..."
cp bird/as500.conf bird/as500.conf.bak

# 2. Inject the fatal misconfiguration (Route Leak)
echo "2. Injecting filter misconfiguration into AS500..."
# We replace its strict filter with "export all;", turning it into a fake transit provider
sed 's/export filter my_networks;/export all; # FATAL ROUTE LEAK/g' bird/as500.conf > temp_leak.conf
cat temp_leak.conf > bird/as500.conf
rm temp_leak.conf

# 3. Apply the misconfiguration
echo "3. Reloading AS500 BIRD router..."
docker exec as500 birdc -s /var/run/bird/bird.ctl configure
echo "Waiting for BGP convergence..."
sleep 3

# 4. Verify the damage on AS600
echo "--------------------------------------------------------"
echo "4. Checking AS600 (Vulnerable Client) routing table:"
docker exec as600 birdc -s /var/run/bird/bird.ctl show route
echo "The leak was SUCCESSFUL! AS600 is now sending internet traffic to AS500!"