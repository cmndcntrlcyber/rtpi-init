#!/usr/bin/env bash

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

# Show help message
function show_help() {
    echo "Utility Script for Docker Environment"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  status      - Show status of all containers"
    echo "  start       - Start all containers"
    echo "  stop        - Stop all containers"
    echo "  restart     - Restart all containers"
    echo "  logs [name] - Show logs for a specific container (or all if no name provided)"
    echo "  shell [name] - Open a shell in a specific container"
    echo "  update      - Update all containers"
    echo "  backup      - Create a backup of all volumes"
    echo "  restore     - Restore backup of all volumes"
    echo "  help        - Show this help message"
}

# Show status of all containers
function show_status() {
    print_message "Showing status of all containers..."
    docker-compose ps
}

# Start all containers
function start_containers() {
    print_message "Starting all containers..."
    docker-compose up -d
}

# Stop all containers
function stop_containers() {
    print_message "Stopping all containers..."
    docker-compose down
}

# Restart all containers
function restart_containers() {
    print_message "Restarting all containers..."
    docker-compose restart
}

# Show logs for a specific container
function show_logs() {
    if [[ -z "$1" ]]; then
        print_message "Showing logs for all containers..."
        docker-compose logs
    else
        print_message "Showing logs for container $1..."
        docker-compose logs "$1"
    fi
}

# Open a shell in a specific container
function open_shell() {
    if [[ -z "$1" ]]; then
        print_error "Please specify a container name."
        return 1
    else
        print_message "Opening shell in container $1..."
        docker exec -it "$1" bash || docker exec -it "$1" sh
    fi
}

# Update all containers
function update_containers() {
    print_message "Updating all containers..."
    docker-compose pull
    docker-compose up -d
}

# Create a backup of all volumes
function backup_volumes() {
    local backup_dir="backup_$(date +%Y%m%d_%H%M%S)"
    print_message "Creating backup of all volumes in directory $backup_dir..."
    mkdir -p "$backup_dir"
    
    # Stop containers
    docker-compose down
    
    # Backup each volume
    for volume in kasm_db_data kasm_profiles kasm_data portainer_data evilginx2_data gophish_data axiom_data; do
        print_message "Backing up volume $volume..."
        docker run --rm -v "$volume:/source" -v "$(pwd)/$backup_dir:/backup" alpine tar -czf "/backup/$volume.tar.gz" -C /source .
    done
    
    # Restart containers
    docker-compose up -d
    
    print_message "Backup completed successfully in directory $backup_dir."
}

# Restore backup of all volumes
function restore_volumes() {
    print_message "Available backups:"
    local backups=(backup_*)
    if [[ ${#backups[@]} -eq 0 ]]; then
        print_error "No backups found."
        return 1
    fi
    
    for i in "${!backups[@]}"; do
        echo "$((i+1)). ${backups[$i]}"
    done
    
    echo "Enter the number of the backup to restore:"
    read -r backup_num
    
    if [[ ! "$backup_num" =~ ^[0-9]+$ ]] || [[ "$backup_num" -lt 1 ]] || [[ "$backup_num" -gt ${#backups[@]} ]]; then
        print_error "Invalid selection."
        return 1
    fi
    
    local backup_dir="${backups[$((backup_num-1))]}"
    
    print_message "Restoring backup from directory $backup_dir..."
    
    # Stop containers
    docker-compose down
    
    # Restore each volume
    for volume in kasm_db_data kasm_profiles kasm_data portainer_data evilginx2_data gophish_data axiom_data; do
        if [[ -f "$backup_dir/$volume.tar.gz" ]]; then
            print_message "Restoring volume $volume..."
            docker run --rm -v "$volume:/destination" -v "$(pwd)/$backup_dir:/backup" alpine sh -c "rm -rf /destination/* && tar -xzf /backup/$volume.tar.gz -C /destination"
        else
            print_warning "Backup for volume $volume not found. Skipping..."
        fi
    done
    
    # Restart containers
    docker-compose up -d
    
    print_message "Restore completed successfully."
}

# Main function
function main() {
    case "$1" in
        status)
            show_status
            ;;
        start)
            start_containers
            ;;
        stop)
            stop_containers
            ;;
        restart)
            restart_containers
            ;;
        logs)
            show_logs "$2"
            ;;
        shell)
            open_shell "$2"
            ;;
        update)
            update_containers
            ;;
        backup)
            backup_volumes
            ;;
        restore)
            restore_volumes
            ;;
        help|*)
            show_help
            ;;
    esac
}

# Execute main function
main "$@"