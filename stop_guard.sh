#!/bin/bash

echo "🛑 STOPPING UNI-GUARD: Disabling blockchain protection..."

# 1. Stop the python security bot
docker compose stop uni-guard

# 2. Clear the blocked prefixes from AS400's memory (reset to safe empty function)
echo "🧹 Clearing AS400 blocklist..."
docker exec as400 sh -c "echo 'function check_blocklist() { return false; }' > /etc/bird/blocklist.conf"

# 3. Reload AS400 so it starts accepting all routes again
echo " Reloading AS400 BIRD configuration..."
docker exec as400 birdc -s /var/run/bird/bird.ctl configure

echo "--------------------------------------------------------"
echo "   Guard Disabled! AS400 is now VULNERABLE."
echo "   If the attack is running, AS400 will now accept the hijack."
echo "   Verify with: docker exec as400 birdc -s /var/run/bird/bird.ctl show route"
echo "--------------------------------------------------------"