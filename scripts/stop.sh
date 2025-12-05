#!/bin/bash

# Server Monitoring Dashboard - Stop Script
# This script stops the monitoring stack

set -e

echo "🛑 Stopping Server Monitoring Dashboard..."

# Stop services
docker-compose down

echo ""
echo "✅ Monitoring stack has been stopped."
echo ""
echo "💡 To start again, run: ./scripts/start.sh"
echo "💡 To remove all data, run: ./scripts/cleanup.sh"
echo ""
