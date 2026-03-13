#!/bin/bash
# volume_attack.sh - BGP-Besu Comprehensive Stress Testing Script

# 4 Specific Targets + 196 Volume Routes = 200 Total Routes
NUM_VOLUME_ROUTES=196 
TARGET_SUBNET="10.100.1" 

echo "======================================================"
echo " STARTING VOLUME BGP ATTACK: Injecting 200 Routes"
echo "======================================================"

echo " 1. Generating specific targets AND volume payload..."

# Step 1: Create the payload locally
echo "protocol static hijack_static {" > temp_payload.txt
echo "    ipv4;" >> temp_payload.txt

# --- THE SPECIFIC TARGETS ---
echo "    route 10.100.0.1/32 unreachable; # Target 1: ROA Violation" >> temp_payload.txt
echo "    route 10.1.0.0/24 unreachable;   # Target 2: ASPA Violation (Spoof AS100)" >> temp_payload.txt
echo "    route 10.2.0.0/24 unreachable;   # Target 3: ASPA Violation (Spoof AS200)" >> temp_payload.txt
echo "    route 10.6.0.0/24 unreachable;   # Target 4: ASPA Violation (Spoof AS600)" >> temp_payload.txt

# --- THE VOLUME BURST (Noise to stress the CPU) ---
for ((i=1; i<=NUM_VOLUME_ROUTES; i++)); do
    echo "    route $TARGET_SUBNET.$i/32 unreachable;" >> temp_payload.txt
done

echo "}" >> temp_payload.txt

# Step 2: Read the payload into a variable
PAYLOAD=$(cat temp_payload.txt)

# Step 3: Inject it into AS500
echo "2. Injecting payload into AS500..."
docker exec as500 sh -c "echo '$PAYLOAD' > /etc/bird/hijack.conf"

# Step 4: Reload BIRD configuration
echo "3. Reloading AS500 BIRD configuration..."
docker exec as500 birdc -s /var/run/bird/bird.ctl configure

# Cleanup
rm temp_payload.txt

echo "--------------------------------------------------------"
echo "   Volume Attack Launched! AS500 just leaked 200 routes."
echo "   Watch Uni-Guard logs to see it calculate mitigation times:"
echo "   docker logs -f uni-guard"