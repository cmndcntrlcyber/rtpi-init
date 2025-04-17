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
DEFAULT_HTTP_PORT=8880
DEFAULT_HTTPS_PORT=8443

# Load environment variables from parent .env if it exists
if [ -f "../.env" ]; then
    source "../.env"
fi

# Create local .env file with default or existing values
print_message "Creating local .env file..."
cat > .env << EOL
# Evilginx2 Configuration
EVILGINX2_HTTP_PORT=${EVILGINX2_HTTP_PORT:-$DEFAULT_HTTP_PORT}
EVILGINX2_HTTPS_PORT=${EVILGINX2_HTTPS_PORT:-$DEFAULT_HTTPS_PORT}
EOL

# Ask if user wants to configure ports
print_message "Do you want to configure the evilginx2 ports? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Ask for HTTP port
    print_message "Enter the HTTP port for Evilginx2 (default: ${EVILGINX2_HTTP_PORT:-$DEFAULT_HTTP_PORT}):"
    read -r http_port
    if [[ -n "$http_port" ]]; then
        sed -i "s/EVILGINX2_HTTP_PORT=.*/EVILGINX2_HTTP_PORT=$http_port/" .env
    fi
    
    # Ask for HTTPS port
    print_message "Enter the HTTPS port for Evilginx2 (default: ${EVILGINX2_HTTPS_PORT:-$DEFAULT_HTTPS_PORT}):"
    read -r https_port
    if [[ -n "$https_port" ]]; then
        sed -i "s/EVILGINX2_HTTPS_PORT=.*/EVILGINX2_HTTPS_PORT=$https_port/" .env
    fi
fi

# Build and start the service
print_message "Building and starting Evilginx2 service..."
docker-compose --env-file .env up -d --build

# Print access information
print_message "Evilginx2 service started!"
source .env
echo -e "Access Evilginx2 at:"
echo -e "HTTP: http://localhost:${EVILGINX2_HTTP_PORT}"
echo -e "HTTPS: https://localhost:${EVILGINX2_HTTPS_PORT}"
echo -e "DNS: localhost:5353/udp"

print_message "To access the Evilginx2 console:"
echo -e "docker exec -it evilginx2 bash"
echo -e "evilginx -p /opt/evilginx/phishlets"

print_warning "For security reasons, use this tool responsibly and legally!"
print_message "To stop the service: docker-compose down"
print_message "To restart the service: docker-compose restart"
