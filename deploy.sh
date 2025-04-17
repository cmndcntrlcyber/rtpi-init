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
      echo "Unknown option: $1"
      echo "Usage: $0 [-a|--auto]"
      echo "  -a, --auto    Run in non-interactive mode, automatically deploying when no conflicts"
      exit 1
      ;;
  esac
done

# Colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
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

# Print a section header
function print_section() {
    echo -e "\n${BLUE}=== $1 ===${NC}\n"
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
print_message "Using Docker Compose command: $DOCKER_COMPOSE"

# Function to check if a port is in use
check_port() {
    port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# Function to configure global environment variables
configure_environment() {
    print_section "Global Environment Configuration"
    
    # Default port values
    DEFAULT_EVILGINX2_HTTP_PORT=8880
    DEFAULT_EVILGINX2_HTTPS_PORT=8443
    DEFAULT_GOPHISH_ADMIN_PORT=3333
    DEFAULT_GOPHISH_PHISH_PORT=8080
    DEFAULT_KASM_PORT=443
    DEFAULT_PORTAINER_PORT=9000
    DEFAULT_NPM_HTTP_PORT=80
    DEFAULT_NPM_ADMIN_PORT=81
    DEFAULT_NPM_HTTPS_PORT=443
    
    # Load existing .env file if it exists
    if [ -f ".env" ]; then
        source .env
    fi
    
    # Create or update .env file with default or existing values
    cat > .env << EOL
# Kasm Workspaces Configuration
KASM_VERSION=${KASM_VERSION:-1.15.0}
PUBLIC_IP=${PUBLIC_IP:-0.0.0.0}
KASM_PORT=${KASM_PORT:-$DEFAULT_KASM_PORT}

# Portainer Configuration
PORTAINER_PORT=${PORTAINER_PORT:-$DEFAULT_PORTAINER_PORT}

# Workspace Configuration
WORKSPACE_PASSWORD=${WORKSPACE_PASSWORD:-password123}

# Evilginx2 Configuration
EVILGINX2_HTTP_PORT=${EVILGINX2_HTTP_PORT:-$DEFAULT_EVILGINX2_HTTP_PORT}
EVILGINX2_HTTPS_PORT=${EVILGINX2_HTTPS_PORT:-$DEFAULT_EVILGINX2_HTTPS_PORT}

# Gophish Configuration
GOPHISH_ADMIN_PORT=${GOPHISH_ADMIN_PORT:-$DEFAULT_GOPHISH_ADMIN_PORT}
GOPHISH_PHISH_PORT=${GOPHISH_PHISH_PORT:-$DEFAULT_GOPHISH_PHISH_PORT}

# Nginx Proxy Manager Configuration
NPM_HTTP_PORT=${NPM_HTTP_PORT:-$DEFAULT_NPM_HTTP_PORT}
NPM_ADMIN_PORT=${NPM_ADMIN_PORT:-$DEFAULT_NPM_ADMIN_PORT}
NPM_HTTPS_PORT=${NPM_HTTPS_PORT:-$DEFAULT_NPM_HTTPS_PORT}

# Database Configuration
DB_HOST=${DB_HOST:-kasm_db}
DB_NAME=${DB_NAME:-kasm}
DB_USER=${DB_USER:-kasmdb}
DB_PASS=${DB_PASS:-kasmdb_password}
DB_PORT=${DB_PORT:-5432}
EOL
    
    print_message "Global environment configuration file created."
    print_message "You can modify the .env file directly or reconfigure during deployment."
}

# Function to deploy a service
deploy_service() {
    service=$1
    print_section "Deploying $service"
    
    # Check if service directory exists
    if [ ! -d "$service" ]; then
        print_error "Service directory $service does not exist."
        return 1
    fi
    
    # Check if deploy.sh exists
    if [ ! -f "$service/deploy.sh" ]; then
        print_error "Deploy script for $service does not exist."
        return 1
    fi
    
    # Make sure the deploy script is executable
    chmod +x "$service/deploy.sh"
    
    # Execute the deploy script with auto flag if in auto mode
    print_message "Executing deployment script for $service..."
    cd "$service"
    if [[ "$AUTO_MODE" == "true" ]]; then
        ./deploy.sh --auto
    else
        ./deploy.sh
    fi
    cd ..
    
    print_message "$service deployment complete."
}

# Function to check for port conflicts
check_for_conflicts() {
    source .env
    conflicts=0
    
    # Define all service ports
    ports=(
        "$KASM_PORT:Kasm:HTTPS"
        "$PORTAINER_PORT:Portainer:HTTP"
        "$EVILGINX2_HTTP_PORT:Evilginx2:HTTP"
        "$EVILGINX2_HTTPS_PORT:Evilginx2:HTTPS"
        "$GOPHISH_ADMIN_PORT:Gophish:Admin"
        "$GOPHISH_PHISH_PORT:Gophish:Phishing"
        "$NPM_HTTP_PORT:Nginx Proxy Manager:HTTP"
        "$NPM_ADMIN_PORT:Nginx Proxy Manager:Admin"
        "$NPM_HTTPS_PORT:Nginx Proxy Manager:HTTPS"
    )
    
    # Check each port
    print_section "Checking for port conflicts"
    
    # First check if any ports are already in use on the host
    for port_info in "${ports[@]}"; do
        IFS=: read -r port service type <<< "$port_info"
        if check_port "$port"; then
            print_error "Port $port ($service $type) is already in use on the host system."
            conflicts=$((conflicts + 1))
        else
            print_message "Port $port ($service $type) is available."
        fi
    done
    
    # Then check for duplicates within our configuration
    declare -A port_map
    for port_info in "${ports[@]}"; do
        IFS=: read -r port service type <<< "$port_info"
        if [[ -v port_map[$port] ]]; then
            print_error "Port conflict: $port is used by both $port_map[$port] and $service $type."
            conflicts=$((conflicts + 1))
        else
            port_map[$port]="$service $type"
        fi
    done
    
    if [ $conflicts -gt 0 ]; then
        print_warning "Found $conflicts port conflicts. Please resolve before deployment."
        print_message "Would you like to reconfigure the ports now? (y/n)"
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            configure_ports
            # Check again after reconfiguration
            check_for_conflicts
        else
            return 1
        fi
    else
        print_message "No port conflicts found."
        return 0
    fi
}

# Function to configure ports
configure_ports() {
    print_section "Port Configuration"
    
    # Load current values
    source .env
    
    # Configure Kasm port
    print_message "Enter the port for Kasm HTTPS (default: ${KASM_PORT}):"
    read -r kasm_port
    if [[ -n "$kasm_port" ]]; then
        sed -i "s/KASM_PORT=.*/KASM_PORT=$kasm_port/" .env
    fi
    
    # Configure Portainer port
    print_message "Enter the port for Portainer (default: ${PORTAINER_PORT}):"
    read -r portainer_port
    if [[ -n "$portainer_port" ]]; then
        sed -i "s/PORTAINER_PORT=.*/PORTAINER_PORT=$portainer_port/" .env
    fi
    
    # Configure Evilginx2 ports
    print_message "Enter the HTTP port for Evilginx2 (default: ${EVILGINX2_HTTP_PORT}):"
    read -r evilginx2_http_port
    if [[ -n "$evilginx2_http_port" ]]; then
        sed -i "s/EVILGINX2_HTTP_PORT=.*/EVILGINX2_HTTP_PORT=$evilginx2_http_port/" .env
    fi
    
    print_message "Enter the HTTPS port for Evilginx2 (default: ${EVILGINX2_HTTPS_PORT}):"
    read -r evilginx2_https_port
    if [[ -n "$evilginx2_https_port" ]]; then
        sed -i "s/EVILGINX2_HTTPS_PORT=.*/EVILGINX2_HTTPS_PORT=$evilginx2_https_port/" .env
    fi
    
    # Configure Gophish ports
    print_message "Enter the admin port for Gophish (default: ${GOPHISH_ADMIN_PORT}):"
    read -r gophish_admin_port
    if [[ -n "$gophish_admin_port" ]]; then
        sed -i "s/GOPHISH_ADMIN_PORT=.*/GOPHISH_ADMIN_PORT=$gophish_admin_port/" .env
    fi
    
    print_message "Enter the phishing port for Gophish (default: ${GOPHISH_PHISH_PORT}):"
    read -r gophish_phish_port
    if [[ -n "$gophish_phish_port" ]]; then
        sed -i "s/GOPHISH_PHISH_PORT=.*/GOPHISH_PHISH_PORT=$gophish_phish_port/" .env
    fi
    
    # Configure Nginx Proxy Manager ports
    print_message "Enter the HTTP port for Nginx Proxy Manager (default: ${NPM_HTTP_PORT}):"
    read -r npm_http_port
    if [[ -n "$npm_http_port" ]]; then
        sed -i "s/NPM_HTTP_PORT=.*/NPM_HTTP_PORT=$npm_http_port/" .env
    fi
    
    print_message "Enter the admin port for Nginx Proxy Manager (default: ${NPM_ADMIN_PORT}):"
    read -r npm_admin_port
    if [[ -n "$npm_admin_port" ]]; then
        sed -i "s/NPM_ADMIN_PORT=.*/NPM_ADMIN_PORT=$npm_admin_port/" .env
    fi
    
    print_message "Enter the HTTPS port for Nginx Proxy Manager (default: ${NPM_HTTPS_PORT}):"
    read -r npm_https_port
    if [[ -n "$npm_https_port" ]]; then
        sed -i "s/NPM_HTTPS_PORT=.*/NPM_HTTPS_PORT=$npm_https_port/" .env
    fi
    
    print_message "Ports configured successfully."
}

# Function to deploy all services
deploy_all_services() {
    print_message "Deploying all services..."
    deploy_service "evilginx2"
    deploy_service "gophish"
    deploy_service "kasm"
    deploy_service "portainer"
    deploy_service "nginx-proxy-manager"
    deploy_service "axiom"
}

# Modified check_for_conflicts for auto mode
auto_check_for_conflicts() {
    source .env
    conflicts=0
    
    # Define all service ports
    ports=(
        "$KASM_PORT:Kasm:HTTPS"
        "$PORTAINER_PORT:Portainer:HTTP"
        "$EVILGINX2_HTTP_PORT:Evilginx2:HTTP"
        "$EVILGINX2_HTTPS_PORT:Evilginx2:HTTPS"
        "$GOPHISH_ADMIN_PORT:Gophish:Admin"
        "$GOPHISH_PHISH_PORT:Gophish:Phishing"
        "$NPM_HTTP_PORT:Nginx Proxy Manager:HTTP"
        "$NPM_ADMIN_PORT:Nginx Proxy Manager:Admin"
        "$NPM_HTTPS_PORT:Nginx Proxy Manager:HTTPS"
    )
    
    # Check each port
    print_section "Checking for port conflicts"
    
    # First check if any ports are already in use on the host
    for port_info in "${ports[@]}"; do
        IFS=: read -r port service type <<< "$port_info"
        if check_port "$port"; then
            print_error "Port $port ($service $type) is already in use on the host system."
            conflicts=$((conflicts + 1))
        else
            print_message "Port $port ($service $type) is available."
        fi
    done
    
    # Then check for duplicates within our configuration
    declare -A port_map
    for port_info in "${ports[@]}"; do
        IFS=: read -r port service type <<< "$port_info"
        if [[ -v port_map[$port] ]]; then
            print_error "Port conflict: $port is used by both $port_map[$port] and $service $type."
            conflicts=$((conflicts + 1))
        else
            port_map[$port]="$service $type"
        fi
    done
    
    if [ $conflicts -gt 0 ]; then
        print_error "Found $conflicts port conflicts. Please resolve them in the .env file and try again."
        return 1
    else
        print_message "No port conflicts found."
        return 0
    fi
}

# Main function for deployment
main() {
    print_section "Red Team Penetration Testing Infrastructure Deployment"
    
    if [[ "$AUTO_MODE" == "true" ]]; then
        # Automated mode
        # Use existing .env file or create one
        if [ ! -f ".env" ]; then
            print_message "No .env file found. Creating default configuration."
            configure_environment
        else
            print_message "Using existing .env file."
        fi
        
        # Check for port conflicts (non-interactive)
        if ! auto_check_for_conflicts; then
            print_error "Port conflicts detected. Exiting."
            exit 1
        fi
        
        # Deploy all services
        deploy_all_services
    else
        # Interactive mode
        # Configure environment if needed
        if [ ! -f ".env" ]; then
            print_message "No .env file found. Creating default configuration."
            configure_environment
        else
            print_message "Existing .env file found."
            print_message "Would you like to reconfigure environment variables? (y/n)"
            read -r answer
            if [[ "$answer" =~ ^[Yy]$ ]]; then
                configure_environment
            fi
        fi
        
        # Check for port conflicts (interactive)
        if ! check_for_conflicts; then
            print_warning "Please resolve port conflicts before proceeding."
            return 1
        fi
        
        # Menu for service selection
        print_section "Service Selection"
        print_message "Select services to deploy:"
        print_message "1) All services"
        print_message "2) Evilginx2"
        print_message "3) Gophish"
        print_message "4) Kasm Workspaces"
        print_message "5) Portainer"
        print_message "6) Nginx Proxy Manager"
        print_message "7) Axiom"
        print_message "0) Exit"
        
        read -r -p "Enter your choice (1-7): " choice
        
        case $choice in
            1)
                deploy_all_services
                ;;
            2)
                deploy_service "evilginx2"
                ;;
            3)
                deploy_service "gophish"
                ;;
            4)
                deploy_service "kasm"
                ;;
            5)
                deploy_service "portainer"
                ;;
            6)
                deploy_service "nginx-proxy-manager"
                ;;
            7)
                deploy_service "axiom"
                ;;
            0)
                print_message "Exiting deployment script."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Exiting."
                exit 1
                ;;
        esac
    fi
    
    print_section "Deployment Complete"
    print_message "Your Red Team infrastructure has been deployed successfully."
    print_warning "For security reasons, please change all default passwords immediately!"
    print_warning "Use these tools responsibly and legally!"
}

# Execute main function
main
