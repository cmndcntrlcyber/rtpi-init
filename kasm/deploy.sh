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

# Default values
DEFAULT_KASM_VERSION="1.15.0"
DEFAULT_KASM_PORT="443"
DEFAULT_DB_HOST="kasm_db"
DEFAULT_DB_NAME="kasm"
DEFAULT_DB_USER="kasmdb"
DEFAULT_DB_PASS="kasmdb_password"
DEFAULT_DB_PORT="5432"
DEFAULT_WORKSPACE_PASSWORD="password123"

# Load environment variables from parent .env if it exists
if [ -f "../.env" ]; then
    source "../.env"
fi

# Create local .env file with default or existing values
print_message "Creating local .env file..."
cat > .env << EOL
# Kasm Workspaces Configuration
KASM_VERSION=${KASM_VERSION:-$DEFAULT_KASM_VERSION}
PUBLIC_IP=${PUBLIC_IP:-0.0.0.0}
KASM_PORT=${KASM_PORT:-$DEFAULT_KASM_PORT}

# Database Configuration
DB_HOST=${DB_HOST:-$DEFAULT_DB_HOST}
DB_NAME=${DB_NAME:-$DEFAULT_DB_NAME}
DB_USER=${DB_USER:-$DEFAULT_DB_USER}
DB_PASS=${DB_PASS:-$DEFAULT_DB_PASS}
DB_PORT=${DB_PORT:-$DEFAULT_DB_PORT}

# Workspace Configuration
WORKSPACE_PASSWORD=${WORKSPACE_PASSWORD:-$DEFAULT_WORKSPACE_PASSWORD}
EOL

# Ask if user wants to configure variables
print_message "Do you want to configure the Kasm Workspaces environment variables? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Ask for KASM_VERSION
    print_message "Enter the Kasm version (default: ${KASM_VERSION:-$DEFAULT_KASM_VERSION}):"
    read -r kasm_version
    if [[ -n "$kasm_version" ]]; then
        sed -i "s/KASM_VERSION=.*/KASM_VERSION=$kasm_version/" .env
    fi
    
    # Ask for KASM_PORT
    print_message "Enter the Kasm port (default: ${KASM_PORT:-$DEFAULT_KASM_PORT}):"
    read -r kasm_port
    if [[ -n "$kasm_port" ]]; then
        sed -i "s/KASM_PORT=.*/KASM_PORT=$kasm_port/" .env
    fi
    
    # Ask for DB_HOST
    print_message "Enter the database host (default: ${DB_HOST:-$DEFAULT_DB_HOST}):"
    read -r db_host
    if [[ -n "$db_host" ]]; then
        sed -i "s/DB_HOST=.*/DB_HOST=$db_host/" .env
    fi
    
    # Ask for DB_NAME
    print_message "Enter the database name (default: ${DB_NAME:-$DEFAULT_DB_NAME}):"
    read -r db_name
    if [[ -n "$db_name" ]]; then
        sed -i "s/DB_NAME=.*/DB_NAME=$db_name/" .env
    fi
    
    # Ask for DB_USER
    print_message "Enter the database user (default: ${DB_USER:-$DEFAULT_DB_USER}):"
    read -r db_user
    if [[ -n "$db_user" ]]; then
        sed -i "s/DB_USER=.*/DB_USER=$db_user/" .env
    fi
    
    # Ask for DB_PASS
    print_message "Enter the database password (default: ${DB_PASS:-$DEFAULT_DB_PASS}):"
    read -r db_pass
    if [[ -n "$db_pass" ]]; then
        sed -i "s/DB_PASS=.*/DB_PASS=$db_pass/" .env
    fi
    
    # Ask for DB_PORT
    print_message "Enter the database port (default: ${DB_PORT:-$DEFAULT_DB_PORT}):"
    read -r db_port
    if [[ -n "$db_port" ]]; then
        sed -i "s/DB_PORT=.*/DB_PORT=$db_port/" .env
    fi
    
    # Ask for WORKSPACE_PASSWORD
    print_message "Enter the workspace password (default: ${WORKSPACE_PASSWORD:-$DEFAULT_WORKSPACE_PASSWORD}):"
    read -r workspace_password
    if [[ -n "$workspace_password" ]]; then
        sed -i "s/WORKSPACE_PASSWORD=.*/WORKSPACE_PASSWORD=$workspace_password/" .env
    fi
fi

# Ensure start.sh is executable
chmod +x start.sh

# Build and start Kasm services
print_message "Building and starting Kasm Workspaces services..."
$DOCKER_COMPOSE --env-file .env up -d --build

# Wait for services to start
print_message "Waiting for services to start (this may take a minute)..."
sleep 30

# Print access information
print_message "Kasm Workspaces services started!"
source .env
echo -e "Access Kasm Workspaces at: https://localhost:${KASM_PORT}"
echo -e "Default admin credentials: admin@kasm.local / password"

print_warning "For security reasons, please change all default passwords immediately!"
print_warning "Use this tool responsibly and legally!"
print_message "To stop all services: $DOCKER_COMPOSE down"
print_message "To restart all services: $DOCKER_COMPOSE restart"
