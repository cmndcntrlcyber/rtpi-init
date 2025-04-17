#!/bin/bash

# Cleanup script for Evilginx2 + Gophish Docker Deployment

echo "Cleaning up Evilginx2 + Gophish Docker Deployment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running or not installed."
    exit 1
fi

# Stop and remove containers
echo "Stopping and removing containers..."
docker-compose down

# Ask if user wants to remove volumes
read -p "Do you want to remove all data (volumes)? This will delete all campaign data, phishlets, and configurations. (y/n): " remove_volumes

if [[ $remove_volumes == "y" || $remove_volumes == "Y" ]]; then
    echo "Removing data directories..."
    rm -rf evilginx2-data
    rm -rf gophish-data
    echo "All data has been removed."
else
    echo "Data directories have been preserved."
fi

# Ask if user wants to remove Docker images
read -p "Do you want to remove the Docker images? (y/n): " remove_images

if [[ $remove_images == "y" || $remove_images == "Y" ]]; then
    echo "Removing Docker images..."
    docker rmi $(docker images -q phishing-combo_evilginx2) 2>/dev/null || true
    docker rmi $(docker images -q phishing-combo_gophish) 2>/dev/null || true
    echo "Docker images have been removed."
else
    echo "Docker images have been preserved."
fi

echo "Cleanup complete!"
