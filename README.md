# RTPI-INIT (Red Team Portable Infrastructure - INIT)

A comprehensive containerized infrastructure for red team operations, penetration testing, and phishing campaigns.

## Overview

This project integrates multiple security tools into a coherent, containerized environment:

- **Kasm Workspaces**: Browser-accessible virtual desktops for security tools
- **Portainer**: Docker container management UI
- **Nginx Proxy Manager**: Web traffic routing with SSL support
- **Evilginx2**: Advanced phishing framework (available as both standalone service and in Kasm workspace)
- **Gophish**: Phishing campaign management (available as both standalone service and in Kasm workspace)
- **Axiom**: Dynamic infrastructure framework for red team operations

## Architecture

The infrastructure consists of:

1. **Kasm Core**: Main server providing virtual desktop access and workspace management
2. **Dedicated Workspaces**:
   - Evilginx2 workspace with persistent storage and profiles
   - Gophish workspace with persistent storage and profiles
3. **Standalone Services**:
   - Evilginx2 service with direct port access
   - Gophish service with direct port access
   - Portainer for container management
   - Nginx Proxy Manager for routing and SSL termination
   - Axiom for dynamic infrastructure

## Prerequisites

- Docker
- Docker Compose
- 8GB+ RAM recommended
- Open ports: 80, 81, 443, 3333, 5353, 6901, 6902, 8080, 8443, 8880, 9000

## Setup Instructions

1. Clone this repository:
   ```bash
   git clone https://github.com/cmndcntrlcyber/rtpi-init.git
   cd rtpi-init
   ```

2. Run the setup script:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   This script will:
   - Create necessary configuration files
   - Set up environment variables (or let you customize them)
   - Start all containers
   - Display access information

3. Test your deployment:
   ```bash
   ./test-deployment.sh
   ```
   
   This will verify that all services are running correctly and accessible.

## Access Information

After installation, you can access the tools at:

- **Kasm Workspaces**: https://localhost:443 (or your configured port)
  - Default credentials: admin@kasm.local / password
- **Portainer**: http://localhost:9000 (or your configured port)
  - Create your admin account on first login
- **Nginx Proxy Manager**: http://localhost:81
  - Default credentials: admin@example.com / changeme
- **Evilginx2 Workspace**: https://localhost:6901
  - Password: password123 (or your configured password)
- **Gophish Workspace**: https://localhost:6902
  - Password: password123 (or your configured password)
- **Evilginx2 Service**:
  - HTTP: Port 8880 (or your configured port)
  - HTTPS: Port 8443 (or your configured port)
  - DNS: Port 5353
- **Gophish Service**:
  - Admin interface: https://localhost:3333 (or your configured port)
    - Default credentials: admin / gophish
  - Phishing interface: http://localhost:8080 (or your configured port)
- **Axiom**: Access through Docker shell:
  ```bash
  docker exec -it axiom bash
  ```

## Workspace Features

### Evilginx2 Workspace

The Evilginx2 workspace provides:
- Full desktop environment accessible via browser
- Persistent storage for phishlets and configurations
- Pre-installed dependencies for Evilginx2
- Desktop shortcut for easy access
- Detailed README with usage instructions

#### Evilginx2 Configuration

The Evilginx2 service is configured according to the official documentation:
- Includes necessary network capabilities (NET_ADMIN, NET_RAW)
- Uses Google DNS servers (8.8.8.8, 8.8.4.4) for reliable DNS resolution
- Includes bind-tools for DNS utilities
- Exposes ports for HTTP (80), HTTPS (443), and DNS (53/udp)
- Persistent storage for configurations and phishlets

### Gophish Workspace

The Gophish workspace provides:
- Full desktop environment accessible via browser
- Persistent storage for campaigns and templates
- Pre-installed dependencies for Gophish
- Desktop shortcut for easy access

## Utility Script

The utility script (`utils.sh`) helps manage the environment:

```bash
chmod +x utils.sh  # Make it executable
./utils.sh help    # Show available commands
```

Available commands:
- `status`: Show status of all containers
- `start`: Start all containers
- `stop`: Stop all containers
- `restart`: Restart all containers
- `logs [name]`: Show logs for a specific container
- `shell [name]`: Open a shell in a specific container
- `update`: Update all containers
- `backup`: Create a backup of all volumes
- `restore`: Restore backup of all volumes

## Volumes and Persistence

All services use Docker volumes for persistent storage:

- `kasm_db_1.15.0`: Database for Kasm Workspaces
- `portainer_data`: Portainer configuration and state
- `npm_data`: Nginx Proxy Manager settings
- `npm_letsencrypt`: SSL certificates
- `evilginx2_workspace_data`: Data for Evilginx2 Kasm workspace
- `gophish_workspace_data`: Data for Gophish Kasm workspace
- `evilginx2_data`: Evilginx2 standalone service data
- `gophish_data`: Gophish standalone service data
- `axiom_data`: Axiom configuration and data

## Integration

This environment features integration between Evilginx2 and Gophish:

- Evilginx2 can be used as a redirector for Gophish campaigns
- Configuration is managed through the `integration-config.json` file
- Both tools can be used independently or together
- The hack_network connects both services for seamless communication

## Cleanup

To clean up the environment:

```bash
./cleanup.sh
```

This script will:
- Stop and remove all containers
- Optionally remove volumes (data)
- Optionally remove Docker images
- Clean up any dangling resources

## Security Considerations

- Change all default passwords immediately after setup
- Use Nginx Proxy Manager to secure internal services with SSL
- Consider using firewall rules to restrict access to management interfaces
- Run behind a VPN for sensitive red team operations
- Ensure you have proper authorization before conducting any phishing campaigns

## Troubleshooting

- **Port conflicts**: Edit the .env file to change port mappings
- **Container failures**: Check logs with `./utils.sh logs [container_name]`
- **Workspace issues**: You can manually execute setup scripts inside containers
- **Performance issues**: Increase Docker resources (CPU/RAM) if workspaces are slow
- **Network issues**: Run `./test-deployment.sh` to verify connectivity between services

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed for educational and authorized security testing purposes only.
Use responsibly and ethically. No warranty provided.
