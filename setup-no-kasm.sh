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
cat > .env.no-kasm << EOL
# Portainer Configuration
PORTAINER_PORT=9000

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
    # Ask for PORTAINER_PORT
    print_message "Enter the port for Portainer (default: 9000):"
    read -r portainer_port
    if [[ -n "$portainer_port" ]]; then
        sed -i "s/PORTAINER_PORT=.*/PORTAINER_PORT=$portainer_port/" .env.no-kasm
    fi
    
    # Ask for EVILGINX2_HTTP_PORT
    print_message "Enter the HTTP port for Evilginx2 (default: 8880):"
    read -r evilginx2_http_port
    if [[ -n "$evilginx2_http_port" ]]; then
        sed -i "s/EVILGINX2_HTTP_PORT=.*/EVILGINX2_HTTP_PORT=$evilginx2_http_port/" .env.no-kasm
    fi
    
    # Ask for EVILGINX2_HTTPS_PORT
    print_message "Enter the HTTPS port for Evilginx2 (default: 8443):"
    read -r evilginx2_https_port
    if [[ -n "$evilginx2_https_port" ]]; then
        sed -i "s/EVILGINX2_HTTPS_PORT=.*/EVILGINX2_HTTPS_PORT=$evilginx2_https_port/" .env.no-kasm
    fi
    
    # Ask for GOPHISH_ADMIN_PORT
    print_message "Enter the admin port for Gophish (default: 3333):"
    read -r gophish_admin_port
    if [[ -n "$gophish_admin_port" ]]; then
        sed -i "s/GOPHISH_ADMIN_PORT=.*/GOPHISH_ADMIN_PORT=$gophish_admin_port/" .env.no-kasm
    fi
    
    # Ask for GOPHISH_PHISH_PORT
    print_message "Enter the phishing port for Gophish (default: 8080):"
    read -r gophish_phish_port
    if [[ -n "$gophish_phish_port" ]]; then
        sed -i "s/GOPHISH_PHISH_PORT=.*/GOPHISH_PHISH_PORT=$gophish_phish_port/" .env.no-kasm
    fi
    
fi

# Create docker-compose-no-kasm.yml
print_message "Creating docker-compose-no-kasm.yml file..."
cat > docker-compose-no-kasm.yml << 'EOL'
version: '3.8'

services:
  # Portainer for container management
  portainer:
    container_name: portainer
    image: portainer/portainer-ce:latest
    restart: unless-stopped
    security_opt:
      - no-new-privileges:true
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - portainer_data:/data
    ports:
      - "${PORTAINER_PORT:-9000}:9000"
    networks:
      - redteam_network


  # Standalone Evilginx2 service
  evilginx2:
    container_name: evilginx2
    build:
      context: ./evilginx2
      dockerfile: Dockerfile
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    ports:
      - "${EVILGINX2_HTTP_PORT:-8880}:80"
      - "${EVILGINX2_HTTPS_PORT:-8443}:443"
      - "5353:53/udp"
    volumes:
      - evilginx2_data:/root/.evilginx
    networks:
      - redteam_network

  # Standalone Gophish service
  gophish:
    container_name: gophish
    build:
      context: ./gophish
      dockerfile: Dockerfile
    restart: unless-stopped
    ports:
      - "${GOPHISH_ADMIN_PORT:-3333}:3333"
      - "${GOPHISH_PHISH_PORT:-8080}:8080"
    volumes:
      - gophish_data:/opt/gophish/data
    networks:
      - redteam_network

  # Axiom (as a service)
  axiom:
    container_name: axiom
    image: ubuntu:20.04
    platform: linux/amd64
    restart: unless-stopped
    command: >
      bash -c "apt update && apt install -y git curl sudo golang wget zip unzip lsb-release && 
      git clone https://github.com/pry0cc/axiom ~/.axiom/ && cd && 
      chmod +x ~/.axiom/interact/axiom-configure && ~/.axiom/interact/axiom-configure --docker && 
      tail -f /dev/null"
    volumes:
      - axiom_data:/root/.axiom
    networks:
      - redteam_network

networks:
  redteam_network:
    driver: bridge

volumes:
  portainer_data:
  evilginx2_data:
  gophish_data:
  axiom_data:
EOL

# Start all containers
print_message "Starting all containers..."
docker-compose -f docker-compose-no-kasm.yml --env-file .env.no-kasm up -d

# Wait for all containers to start
print_message "Waiting for all containers to start..."
sleep 10

# Print access information
print_message "Setup complete! Access your services at:"
source .env.no-kasm
echo -e "Portainer: http://localhost:${PORTAINER_PORT} (create your admin account on first login)"
echo -e "Evilginx2 Service: Access ports ${EVILGINX2_HTTP_PORT}(HTTP), ${EVILGINX2_HTTPS_PORT}(HTTPS), and 5353(DNS)"
echo -e "Gophish Admin: https://localhost:${GOPHISH_ADMIN_PORT} (default credentials: admin / gophish)"
echo -e "Gophish Phishing: http://localhost:${GOPHISH_PHISH_PORT}"
echo -e "Axiom: Access through docker exec -it axiom bash"

print_warning "IMPORTANT: For security reasons, please change all default passwords immediately!"
print_message "To stop all services: docker-compose -f docker-compose-no-kasm.yml down"
print_message "To start all services: docker-compose -f docker-compose-no-kasm.yml up -d"
