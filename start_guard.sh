#!/bin/bash

echo "🛡️ STARTING UNI-GUARD: Enabling blockchain protection..."

# Start the python security bot
docker compose start uni-guard

echo "--------------------------------------------------------"
echo "✅ Guard Enabled! Uni-Guard is now scanning BGP tables."
echo "   Watch it detect and filter hijacks in real-time:"
echo "   docker logs -f uni-guard"
echo "--------------------------------------------------------"