#!/usr/bin/env bash
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

# Make setup scripts executable
print_message "Making setup scripts executable..."
chmod +x setup-evilginx2.sh setup-gophish.sh

# Create .env file with default values
print_message "Creating .env file with default values..."
cat > .env << EOL
# Kasm Workspaces Configuration
KASM_VERSION=latest
PUBLIC_IP=127.0.0.1
KASM_PORT=443

# Portainer Configuration
PORTAINER_PORT=9000

# Workspace Configuration
WORKSPACE_PASSWORD=password123

# Evilginx2 Configuration
EVILGINX2_HTTP_PORT=8880
EVILGINX2_HTTPS_PORT=8443

# Gophish Configuration
GOPHISH_ADMIN_PORT=3333
GOPHISH_PHISH_PORT=8080
EOL

# Ask for configuration
print_message "Do you want to configure the environment variables? (y/n)"
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    # Ask for PUBLIC_IP
    print_message "Enter your public IP address (default: 127.0.0.1):"
    read -r ip
    if [[ -n "$ip" ]]; then
        sed -i "s/PUBLIC_IP=.*/PUBLIC_IP=$ip/" .env
    fi
    
    # Ask for KASM_PORT
    print_message "Enter the port for Kasm Workspaces (default: 443):"
    read -r kasm_port
    if [[ -n "$kasm_port" ]]; then
        sed -i "s/KASM_PORT=.*/KASM_PORT=$kasm_port/" .env
    fi
    
    # Ask for PORTAINER_PORT
    print_message "Enter the port for Portainer (default: 9000):"
    read -r portainer_port
    if [[ -n "$portainer_port" ]]; then
        sed -i "s/PORTAINER_PORT=.*/PORTAINER_PORT=$portainer_port/" .env
    fi
    
    # Ask for WORKSPACE_PASSWORD
    print_message "Enter the password for Kasm workspaces (default: password123):"
    read -r workspace_password
    if [[ -n "$workspace_password" ]]; then
        sed -i "s/WORKSPACE_PASSWORD=.*/WORKSPACE_PASSWORD=$workspace_password/" .env
    fi
    
    # Ask for EVILGINX2_HTTP_PORT
    print_message "Enter the HTTP port for Evilginx2 (default: 8880):"
    read -r evilginx2_http_port
    if [[ -n "$evilginx2_http_port" ]]; then
        sed -i "s/EVILGINX2_HTTP_PORT=.*/EVILGINX2_HTTP_PORT=$evilginx2_http_port/" .env
    fi
    
    # Ask for EVILGINX2_HTTPS_PORT
    print_message "Enter the HTTPS port for Evilginx2 (default: 8443):"
    read -r evilginx2_https_port
    if [[ -n "$evilginx2_https_port" ]]; then
        sed -i "s/EVILGINX2_HTTPS_PORT=.*/EVILGINX2_HTTPS_PORT=$evilginx2_https_port/" .env
    fi
    
    # Ask for GOPHISH_ADMIN_PORT
    print_message "Enter the admin port for Gophish (default: 3333):"
    read -r gophish_admin_port
    if [[ -n "$gophish_admin_port" ]]; then
        sed -i "s/GOPHISH_ADMIN_PORT=.*/GOPHISH_ADMIN_PORT=$gophish_admin_port/" .env
    fi
    
    # Ask for GOPHISH_PHISH_PORT
    print_message "Enter the phishing port for Gophish (default: 8080):"
    read -r gophish_phish_port
    if [[ -n "$gophish_phish_port" ]]; then
        sed -i "s/GOPHISH_PHISH_PORT=.*/GOPHISH_PHISH_PORT=$gophish_phish_port/" .env
    fi
fi

# Start all containers
print_message "Starting all containers..."
docker-compose up -d

# Wait for all containers to start
print_message "Waiting for all containers to start..."
sleep 10

# Print access information
print_message "Setup complete! Access your services at:"
source .env
echo -e "Kasm Workspaces: https://localhost:${KASM_PORT} (default credentials: admin@kasm.local / password)"
echo -e "Portainer: http://localhost:${PORTAINER_PORT} (create your admin account on first login)"
echo -e "Nginx Proxy Manager: http://localhost:81 (default credentials: admin@example.com / changeme)"
echo -e "Evilginx2 Workspace: https://localhost:6901 (password: ${WORKSPACE_PASSWORD})"
echo -e "Gophish Workspace: https://localhost:6902 (password: ${WORKSPACE_PASSWORD})"
echo -e "Evilginx2 Service: Access ports ${EVILGINX2_HTTP_PORT}(HTTP), ${EVILGINX2_HTTPS_PORT}(HTTPS), and 5353(DNS)"
echo -e "Gophish Admin: https://localhost:${GOPHISH_ADMIN_PORT} (default credentials: admin / gophish)"
echo -e "Gophish Phishing: http://localhost:${GOPHISH_PHISH_PORT}"
echo -e "Axiom: Access through docker exec -it axiom bash"

print_warning "IMPORTANT: For security reasons, please change all default passwords immediately!"
print_message "To manage your containers, use: ./utils.sh [command]"
