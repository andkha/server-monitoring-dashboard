#!/bin/bash

# Server Monitoring Dashboard - Cleanup Script
# This script removes all containers and volumes

set -e

echo "🧹 Cleaning up Server Monitoring Dashboard..."
echo ""
echo "⚠️  WARNING: This will remove all monitoring data!"
echo "   - All containers will be removed"
echo "   - All volumes (Prometheus data, Grafana dashboards) will be deleted"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Stop and remove containers and volumes
docker compose down -v

echo ""
echo "✅ Cleanup complete!"
echo "💡 To start fresh, run: ./scripts/start.sh"
echo ""
