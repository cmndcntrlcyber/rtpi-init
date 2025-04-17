#!/bin/bash
set -e

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Print a colored message
function print_message() {
    echo -e "${GREEN}[+] $1${NC}"
}

# Print a warning message
function print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

# Print an error message
function print_error() {
    echo -e "${RED}[-] $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Default port values
DEFAULT_PORTAINER_PORT=9000

# Load environment variables from parent .env if it exists
if [ -f "../.env" ]; then
    source "../.env"
fi

# Create local .env file with default or existing values
print_message "Creating local .env file..."
cat > .env << EOL
# Portainer Configuration
PORTAINER_PORT=${PORTAINER_PORT:-$DEFAULT_PORTAINER_PORT}
EOL

# Ask if user wants to configure ports
print_message "Do you want to configure the Portainer port? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Ask for Portainer port
    print_message "Enter the port for Portainer (default: ${PORTAINER_PORT:-$DEFAULT_PORTAINER_PORT}):"
    read -r portainer_port
    if [[ -n "$portainer_port" ]]; then
        sed -i "s/PORTAINER_PORT=.*/PORTAINER_PORT=$portainer_port/" .env
    fi
fi

# Build and start Portainer
print_message "Building and starting Portainer..."
docker-compose --env-file .env up -d --build

# Print access information
print_message "Portainer service started!"
source .env
echo -e "Access Portainer at: http://localhost:${PORTAINER_PORT}"
echo -e "Create your admin account on first login."

print_message "To stop the service: docker-compose down"
print_message "To restart the service: docker-compose restart"
