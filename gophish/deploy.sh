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
DEFAULT_ADMIN_PORT=3333
DEFAULT_PHISH_PORT=8080

# Load environment variables from parent .env if it exists
if [ -f "../.env" ]; then
    source "../.env"
fi

# Create local .env file with default or existing values
print_message "Creating local .env file..."
cat > .env << EOL
# Gophish Configuration
GOPHISH_ADMIN_PORT=${GOPHISH_ADMIN_PORT:-$DEFAULT_ADMIN_PORT}
GOPHISH_PHISH_PORT=${GOPHISH_PHISH_PORT:-$DEFAULT_PHISH_PORT}
EOL

# Ask if user wants to configure ports
print_message "Do you want to configure the Gophish ports? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Ask for admin port
    print_message "Enter the admin port for Gophish (default: ${GOPHISH_ADMIN_PORT:-$DEFAULT_ADMIN_PORT}):"
    read -r admin_port
    if [[ -n "$admin_port" ]]; then
        sed -i "s/GOPHISH_ADMIN_PORT=.*/GOPHISH_ADMIN_PORT=$admin_port/" .env
    fi
    
    # Ask for phishing port
    print_message "Enter the phishing port for Gophish (default: ${GOPHISH_PHISH_PORT:-$DEFAULT_PHISH_PORT}):"
    read -r phish_port
    if [[ -n "$phish_port" ]]; then
        sed -i "s/GOPHISH_PHISH_PORT=.*/GOPHISH_PHISH_PORT=$phish_port/" .env
    fi
fi

# Check if integration-config.json exists
if [ ! -f "../integration-config.json" ]; then
    print_warning "integration-config.json not found in parent directory."
    print_message "Creating a default integration-config.json file..."
    
    cat > ../integration-config.json << EOL
{
    "evilginx2": {
        "url": "http://evilginx2:80",
        "api_key": "your_evilginx2_api_key_here"
    }
}
EOL
    print_message "Created default integration-config.json. Please update it with your actual API keys."
fi

# Build and start the service
print_message "Building and starting Gophish service..."
$DOCKER_COMPOSE --env-file .env up -d --build

# Print access information
print_message "Gophish service started!"
source .env
echo -e "Access Gophish at:"
echo -e "Admin interface: https://localhost:${GOPHISH_ADMIN_PORT} (default credentials: admin / gophish)"
echo -e "Phishing server: http://localhost:${GOPHISH_PHISH_PORT}"

print_warning "For security reasons, please change the default password immediately!"
print_warning "Use this tool responsibly and legally!"
print_message "To stop the service: $DOCKER_COMPOSE down"
print_message "To restart the service: $DOCKER_COMPOSE restart"
