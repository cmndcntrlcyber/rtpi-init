#!/bin/bash

# Test script for Evilginx2 + Gophish Docker Deployment

echo "Testing Evilginx2 + Gophish Docker Deployment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running or not installed."
    exit 1
fi

# Check if containers are running
if ! docker ps | grep -q "evilginx2"; then
    echo "Error: evilginx2 container is not running."
    echo "Try running 'docker-compose up -d' to start the services."
    exit 1
fi

if ! docker ps | grep -q "gophish"; then
    echo "Error: gophish container is not running."
    echo "Try running 'docker-compose up -d' to start the services."
    exit 1
fi

echo "Both containers are running."

# Test network connectivity between containers
echo "Testing network connectivity between containers..."
docker exec gophish ping -c 2 evilginx2 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Network connectivity test passed: gophish can reach evilginx2."
else
    echo "Network connectivity test failed: gophish cannot reach evilginx2."
    echo "Check your Docker network configuration."
fi

# Check if Gophish admin interface is accessible
echo "Testing Gophish admin interface..."
curl -s -o /dev/null -w "%{http_code}" http://localhost:3333 > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Gophish admin interface is accessible at http://localhost:3333"
else
    echo "Cannot access Gophish admin interface at http://localhost:3333"
    echo "Check if the port is correctly mapped and the service is running."
fi

echo "Test complete."
echo "For more detailed testing, access the Gophish admin interface at http://localhost:3333"
echo "Default credentials: admin:gophish"
echo "To access Evilginx2, run: docker exec -it evilginx2 /bin/sh"
