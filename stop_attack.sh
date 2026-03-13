#!/bin/bash

echo "🛑 STOPPING ATTACK: Withdrawing malicious routes from AS500..."

# 1. Empty the hijack configuration file
docker exec as500 sh -c "> /etc/bird/hijack.conf"

# 2. Reload BIRD configuration
echo " Reloading AS500 BIRD configuration..."
docker exec as500 birdc -s /var/run/bird/bird.ctl configure

echo " Attack Stopped! The BGP withdrawal has been sent. The network will normalize."