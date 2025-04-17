#!/bin/bash

# Cleanup script for RTPI Penetration Testing Environment

echo "Cleaning up RTPI Penetration Testing Environment..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running or not installed."
    exit 1
fi

# Stop and remove containers
echo "Stopping and removing containers..."
docker-compose down

# Ask if user wants to remove volumes
read -p "Do you want to remove all data (volumes)? This will delete all campaign data, configurations, and workspaces. (y/n): " remove_volumes

if [[ $remove_volumes == "y" || $remove_volumes == "Y" ]]; then
    echo "Removing volumes..."
    docker volume rm $(docker volume ls -q -f name=rtpi-init_) 2>/dev/null || true
    echo "All volumes have been removed."
else
    echo "Volumes have been preserved."
fi

# Ask if user wants to remove Docker images
read -p "Do you want to remove the Docker images? (y/n): " remove_images

if [[ $remove_images == "y" || $remove_images == "Y" ]]; then
    echo "Removing Docker images..."
    # Remove custom built images
    docker rmi $(docker images -q rtpi-init_evilginx2) 2>/dev/null || true
    docker rmi $(docker images -q rtpi-init_gophish) 2>/dev/null || true
    
    # Ask if user wants to remove all related images including Kasm, Portainer, etc.
    read -p "Do you want to remove all related images including Kasm, Portainer, etc.? (y/n): " remove_all_images
    
    if [[ $remove_all_images == "y" || $remove_all_images == "Y" ]]; then
        docker rmi $(docker images -q kasmweb/agent) 2>/dev/null || true
        docker rmi $(docker images -q kasmweb/api) 2>/dev/null || true
        docker rmi $(docker images -q kasmweb/kasm-guac) 2>/dev/null || true
        docker rmi $(docker images -q kasmweb/manager) 2>/dev/null || true
        docker rmi $(docker images -q kasmweb/nginx) 2>/dev/null || true
        docker rmi $(docker images -q kasmweb/share) 2>/dev/null || true
        docker rmi $(docker images -q kasmweb/ubuntu-focal-desktop) 2>/dev/null || true
        docker rmi $(docker images -q portainer/portainer-ce) 2>/dev/null || true
        docker rmi $(docker images -q jc21/nginx-proxy-manager) 2>/dev/null || true
        docker rmi $(docker images -q postgres:12-alpine) 2>/dev/null || true
        docker rmi $(docker images -q redis:5-alpine) 2>/dev/null || true
        docker rmi $(docker images -q ubuntu:20.04) 2>/dev/null || true
    fi
    
    echo "Docker images have been removed."
else
    echo "Docker images have been preserved."
fi

# Clean up any dangling images
read -p "Do you want to clean up dangling images and unused volumes? (y/n): " cleanup_dangling

if [[ $cleanup_dangling == "y" || $cleanup_dangling == "Y" ]]; then
    echo "Cleaning up dangling images and unused volumes..."
    docker system prune -f
    echo "Cleanup complete."
fi

echo "Environment cleanup complete!"
