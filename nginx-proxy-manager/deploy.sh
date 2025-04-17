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
DEFAULT_NPM_HTTP_PORT=80
DEFAULT_NPM_ADMIN_PORT=81
DEFAULT_NPM_HTTPS_PORT=443

# Load environment variables from parent .env if it exists
if [ -f "../.env" ]; then
    source "../.env"
fi

# Create local .env file with default or existing values
print_message "Creating local .env file..."
cat > .env << EOL
# Nginx Proxy Manager Configuration
NPM_HTTP_PORT=${NPM_HTTP_PORT:-$DEFAULT_NPM_HTTP_PORT}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT:-$DEFAULT_NPM_ADMIN_PORT}
NPM_HTTPS_PORT=${NPM_HTTPS_PORT:-$DEFAULT_NPM_HTTPS_PORT}
EOL

# Ask if user wants to configure ports
print_message "Do you want to configure the Nginx Proxy Manager ports? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Ask for HTTP port
    print_message "Enter the HTTP port for Nginx Proxy Manager (default: ${NPM_HTTP_PORT:-$DEFAULT_NPM_HTTP_PORT}):"
    read -r http_port
    if [[ -n "$http_port" ]]; then
        sed -i "s/NPM_HTTP_PORT=.*/NPM_HTTP_PORT=$http_port/" .env
    fi
    
    # Ask for Admin port
    print_message "Enter the Admin port for Nginx Proxy Manager (default: ${NPM_ADMIN_PORT:-$DEFAULT_NPM_ADMIN_PORT}):"
    read -r admin_port
    if [[ -n "$admin_port" ]]; then
        sed -i "s/NPM_ADMIN_PORT=.*/NPM_ADMIN_PORT=$admin_port/" .env
    fi
    
    # Ask for HTTPS port
    print_message "Enter the HTTPS port for Nginx Proxy Manager (default: ${NPM_HTTPS_PORT:-$DEFAULT_NPM_HTTPS_PORT}):"
    read -r https_port
    if [[ -n "$https_port" ]]; then
        sed -i "s/NPM_HTTPS_PORT=.*/NPM_HTTPS_PORT=$https_port/" .env
    fi
fi

# Build and start Nginx Proxy Manager
print_message "Building and starting Nginx Proxy Manager..."
docker-compose --env-file .env up -d

# Print access information
print_message "Nginx Proxy Manager service started!"
source .env
echo -e "Access Nginx Proxy Manager at:"
echo -e "Admin UI: http://localhost:${NPM_ADMIN_PORT}"
echo -e "Default credentials: admin@example.com / changeme"

print_warning "For security reasons, please change the default password immediately!"
print_message "To stop the service: docker-compose down"
print_message "To restart the service: docker-compose restart"
