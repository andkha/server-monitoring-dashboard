#!/bin/bash

# Server Monitoring Dashboard - Logs Script
# This script shows logs from all services or a specific service

SERVICE=${1:-}

if [ -z "$SERVICE" ]; then
    echo "📋 Showing logs from all services..."
    echo "   Use Ctrl+C to exit"
    echo ""
    docker compose logs -f
else
    echo "📋 Showing logs for $SERVICE..."
    echo "   Use Ctrl+C to exit"
    echo ""
    docker compose logs -f "$SERVICE"
fi
