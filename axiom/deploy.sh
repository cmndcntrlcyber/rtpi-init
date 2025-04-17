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

# Create empty .env file since Axiom doesn't need special configuration
touch .env

# Build and start Axiom
print_message "Building and starting Axiom service..."
$DOCKER_COMPOSE up -d

# Print access information
print_message "Axiom service started!"
echo -e "Access Axiom through docker exec:"
echo -e "docker exec -it axiom bash"
echo -e "Then use the axiom commands as needed."

print_message "To stop the service: $DOCKER_COMPOSE down"
print_message "To restart the service: $DOCKER_COMPOSE restart"

print_warning "Note: Initial setup may take some time as Axiom downloads and configures dependencies."
print_warning "Use this tool responsibly and legally!"
