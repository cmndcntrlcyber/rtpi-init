#!/bin/bash
set -e

# Default to interactive mode
AUTO_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -a|--auto)
      AUTO_MODE=true
      shift
      ;;
    *)
      shift
      ;;
  esac
done

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

# Check if Docker Compose is installed (either docker-compose or docker compose)
if command -v docker-compose &> /dev/null; then
    DOCKER_COMPOSE="docker-compose"
elif docker compose version &> /dev/null; then
    DOCKER_COMPOSE="docker compose"
else
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

# Configure ports if not in auto mode
if [[ "$AUTO_MODE" != "true" ]]; then
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
else
    print_message "Running in auto mode with current port configuration."
fi

# Build and start Portainer
print_message "Building and starting Portainer..."
$DOCKER_COMPOSE --env-file .env up -d --build

# Print access information
print_message "Portainer service started!"
source .env
echo -e "Access Portainer at: http://localhost:${PORTAINER_PORT}"
echo -e "Create your admin account on first login."

print_message "To stop the service: $DOCKER_COMPOSE down"
print_message "To restart the service: $DOCKER_COMPOSE restart"
