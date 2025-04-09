# RTPI-INIT (Red Team Portable Infrastructure - INIT)
A pentesting flavor of the Red Team Portable Infrastructure

## Docker Environment Setup

This repository contains a comprehensive Docker setup for multiple security tools and environments:

- **Kasm Workspaces**: Browser-based containerized desktops
- **Portainer**: Docker management UI
- **Evilginx2**: Phishing framework
- **Gophish**: Phishing campaign framework
- **Axiom**: Dynamic infrastructure framework

## Prerequisites

- Docker
- Docker Compose
- Linux/macOS environment (Windows with WSL2 should also work)

## Installation

1. Clone this repository:
```bash
git clone https://github.com/cmndcntrlcyber/rtpi-init.git
cd rtpi-init
```

2. Make the setup script executable:
```bash
chmod +x setup.sh
```

3. Run the setup script:
```bash
./setup.sh
```

The script will:
- Create necessary directories
- Set up default environment variables (or let you customize them)
- Start all containers
- Display access information

## Accessing the Tools

After installation, you can access the tools at:

- **Kasm Workspaces**: https://localhost:443 (or the port you configured)
  - Default credentials: admin@kasm.local / password
- **Portainer**: http://localhost:9000 (or the port you configured)
  - Create your admin account on first login
- **Gophish**:
  - Admin interface: https://localhost:3333 (or the port you configured)
    - Default credentials: admin / gophish
  - Phishing interface: http://localhost:8080 (or the port you configured)
- **Evilginx2**: Access through Docker shell:
  ```bash
  docker exec -it evilginx2 bash
  evilginx
  ```
- **Axiom**: Access through Docker shell:
  ```bash
  docker exec -it axiom bash
  ```

## Utility Script

A utility script (`utils.sh`) is included to help manage the environment:

```bash
chmod +x utils.sh  # Make it executable
./utils.sh help    # Show available commands
```

Available commands:
- `status`: Show status of all containers
- `start`: Start all containers
- `stop`: Stop all containers
- `restart`: Restart all containers
- `logs [name]`: Show logs for a specific container (or all if no name provided)
- `shell [name]`: Open a shell in a specific container
- `update`: Update all containers
- `backup`: Create a backup of all volumes
- `restore`: Restore backup of all volumes

## Directory Structure

```
.
├── docker-compose.yml      # Main docker-compose configuration
├── .env                    # Environment variables
├── evilginx2/              # Evilginx2 files
│   └── Dockerfile          # Evilginx2 Dockerfile
├── gophish/                # Gophish files
│   └── Dockerfile          # Gophish Dockerfile
├── setup.sh                # Setup script
├── utils.sh                # Utility script
└── README.md               # This README
```

## Security Considerations

- This setup contains penetration testing tools. Ensure you use them ethically and legally.
- Change all default passwords immediately after setup.
- Consider using a firewall to restrict access to sensitive services.
- For production use, consider implementing TLS for all services and proper authentication.

## Troubleshooting

- **Port conflicts**: If you encounter port conflicts, modify the .env file and restart the containers.
- **Container failures**: Check the logs with `./utils.sh logs [container_name]`.
- **Permission issues**: Make sure Docker has appropriate permissions.

## Backup and Restore

To backup all data:
```bash
./utils.sh backup
```

To restore a backup:
```bash
./utils.sh restore
```

This will create/restore backups of all Docker volumes used by the services.

## Updating

To update all containers to their latest versions:
```bash
./utils.sh update
```

## License

Use responsibly and legally. No warranty provided.