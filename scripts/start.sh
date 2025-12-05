#!/bin/bash

# Server Monitoring Dashboard - Start Script
# This script starts the monitoring stack

set -e

echo "🚀 Starting Server Monitoring Dashboard..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Create necessary directories if they don't exist
mkdir -p prometheus grafana/provisioning/datasources grafana/provisioning/dashboards alertmanager

# Pull latest images
echo "📦 Pulling latest images..."
docker compose pull

# Start services
echo "🔧 Starting services..."
docker compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 5

# Check service status
echo ""
echo "📊 Service Status:"
docker compose ps

echo ""
echo "✅ Monitoring stack is up and running!"
echo ""
echo "🌐 Access URLs:"
echo "   - Grafana:      http://localhost:3000 (admin/admin)"
echo "   - Prometheus:   http://localhost:9090"
echo "   - AlertManager: http://localhost:9093"
echo "   - Node Exporter: http://localhost:9100/metrics"
echo ""
echo "📝 Next steps:"
echo "   1. Access Grafana at http://localhost:3000"
echo "   2. Login with admin/admin (change password on first login)"
echo "   3. View the 'Server Monitoring Dashboard'"
echo "   4. Add remote servers by editing prometheus/prometheus.yml"
echo ""
