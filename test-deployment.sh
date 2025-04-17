#!/bin/bash

# Test script for RTPI Penetration Testing Environment

echo "Testing RTPI Penetration Testing Environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running or not installed."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Error: docker-compose is not installed."
    exit 1
fi

# Check if containers are running
echo "Checking container status..."
docker-compose ps

# Check if key services are running
echo -e "\nChecking key services..."

# Check Portainer
if docker ps | grep -q "portainer"; then
    echo "✅ Portainer is running"
else
    echo "❌ Portainer is not running"
fi

# Check Evilginx2
if docker ps | grep -q "evilginx2"; then
    echo "✅ Evilginx2 is running"
else
    echo "❌ Evilginx2 is not running"
fi

# Check Gophish
if docker ps | grep -q "gophish"; then
    echo "✅ Gophish is running"
else
    echo "❌ Gophish is not running"
fi

# Check Kasm services
if docker ps | grep -q "kasm_proxy"; then
    echo "✅ Kasm services are running"
else
    echo "❌ Kasm services are not running"
fi

# Test network connectivity between containers
echo -e "\nTesting network connectivity between containers..."

# Test Gophish to Evilginx2
echo "Testing Gophish to Evilginx2 connectivity..."
if docker exec gophish ping -c 2 evilginx2 > /dev/null 2>&1; then
    echo "✅ Network connectivity test passed: Gophish can reach Evilginx2"
else
    echo "❌ Network connectivity test failed: Gophish cannot reach Evilginx2"
fi

# Test port accessibility
echo -e "\nTesting port accessibility..."

# Source .env file to get port configurations
if [ -f .env ]; then
    source .env
fi

# Set default values if not defined in .env
PORTAINER_PORT=${PORTAINER_PORT:-9000}
GOPHISH_ADMIN_PORT=${GOPHISH_ADMIN_PORT:-3333}
EVILGINX2_HTTP_PORT=${EVILGINX2_HTTP_PORT:-8880}

# Check Portainer port
echo "Testing Portainer port ${PORTAINER_PORT}..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORTAINER_PORT} > /dev/null 2>&1; then
    echo "✅ Portainer is accessible at http://localhost:${PORTAINER_PORT}"
else
    echo "❌ Cannot access Portainer at http://localhost:${PORTAINER_PORT}"
fi

# Check Gophish admin port
echo "Testing Gophish admin port ${GOPHISH_ADMIN_PORT}..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:${GOPHISH_ADMIN_PORT} > /dev/null 2>&1; then
    echo "✅ Gophish admin interface is accessible at http://localhost:${GOPHISH_ADMIN_PORT}"
else
    echo "❌ Cannot access Gophish admin interface at http://localhost:${GOPHISH_ADMIN_PORT}"
fi

# Check Evilginx2 HTTP port
echo "Testing Evilginx2 HTTP port ${EVILGINX2_HTTP_PORT}..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:${EVILGINX2_HTTP_PORT} > /dev/null 2>&1; then
    echo "✅ Evilginx2 HTTP is accessible at http://localhost:${EVILGINX2_HTTP_PORT}"
else
    echo "❌ Cannot access Evilginx2 HTTP at http://localhost:${EVILGINX2_HTTP_PORT}"
fi

echo -e "\nTest complete."
echo "For more detailed testing:"
echo "- Portainer: http://localhost:${PORTAINER_PORT}"
echo "- Gophish admin: http://localhost:${GOPHISH_ADMIN_PORT} (default credentials: admin/gophish)"
echo "- Evilginx2 Workspace: https://localhost:6901 (password: ${WORKSPACE_PASSWORD:-password123})"
echo "- Gophish Workspace: https://localhost:6902 (password: ${WORKSPACE_PASSWORD:-password123})"
