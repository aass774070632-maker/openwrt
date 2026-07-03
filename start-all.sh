#!/bin/bash
# ALemprator Project - Unified Startup Script
# This official script starts the entire OTA stack and local gateway.

set -e

PROJECT_DIR="/home/galal/openwrt/ota-server"

echo "--------------------------------------------------------"
echo "🚀 Starting ALemprator OTA Infrastructure..."
echo "👤 User: galal"
echo "📂 Path: $PROJECT_DIR"
echo "--------------------------------------------------------"

# 1. Check if Docker is running
if ! sudo docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker is not running or sudo required."
    exit 1
fi

# 2. Start the Docker Compose stack
cd "$PROJECT_DIR"
echo "📦 Pulling/Building and starting containers..."
sudo docker compose up -d

# 3. Wait for the API and Nginx gateway
echo "⏳ Waiting for services to initialize..."
MAX_RETRIES=15
COUNT=0
HEALTH_URL="http://127.0.0.1/api/health"

until $(curl -fsS "$HEALTH_URL" > /dev/null 2>&1); do
    if [ $COUNT -ge $MAX_RETRIES ]; then
        echo "❌ Timeout: Services are not responding at $HEALTH_URL"
        echo "🔍 Checking logs..."
        sudo docker compose logs --tail=20 api
        exit 1
    fi
    echo "   ...waiting for health check ($((COUNT+1))/$MAX_RETRIES)"
    sleep 4
    COUNT=$((COUNT+1))
done

echo "--------------------------------------------------------"
echo "✅ SUCCESS: All services are UP and Healthy!"
echo "--------------------------------------------------------"
echo "🌐 Local Admin:   http://127.0.0.1/admin-app/"
echo "🌐 Public OTA:    https://ota.kartnet.org"
echo "📊 API Status:    $(curl -s http://127.0.0.1/api/health)"
echo "--------------------------------------------------------"
echo "💡 Use 'sudo docker compose logs -f' in the ota-server dir to follow logs."
echo "--------------------------------------------------------"
