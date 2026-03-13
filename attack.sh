#!/bin/bash

echo "STARTING DUAL BGP ATTACK: ROA Hijack & ASPA Spoofing..."
echo "--------------------------------------------------------"

# 1. Overwrite the dynamic include file with BOTH malicious routes
echo "!. Injecting malicious static routes into AS500..."
docker exec as500 sh -c "echo 'protocol static hijack_static { 
    ipv4; 
    route 10.7.0.0/24 unreachable; 
    route 10.100.0.1/32 unreachable; # Payload 1 (ROA)
    route 10.1.0.0/24 unreachable;   # Payload 2 (ASPA)
}' > /etc/bird/hijack.conf"

# 2. Reload BIRD configuration gracefully
echo "2. Reloading AS500 BIRD configuration..."
docker exec as500 birdc -s /var/run/bird/bird.ctl configure

echo "--------------------------------------------------------"
echo "   Attacks Launched! AS500 is now attacking the network."
echo "   Watch Uni-Guard logs to see it block both attacks:"
echo "   docker logs -f uni-guard"