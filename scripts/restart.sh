#!/bin/bash

# Server Monitoring Dashboard - Restart Script
# This script restarts the monitoring stack

set -e

echo "🔄 Restarting Server Monitoring Dashboard..."

# Restart services
docker-compose restart

echo ""
echo "✅ Monitoring stack has been restarted."
echo ""
