#!/bin/bash
set -e

# Configure database connection
sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-kasm_db}/" /opt/kasm/current/conf/app/api.app.config
sed -i "s/DB_NAME=.*/DB_NAME=${DB_NAME:-kasm}/" /opt/kasm/current/conf/app/api.app.config
sed -i "s/DB_USER=.*/DB_USER=${DB_USER:-kasmdb}/" /opt/kasm/current/conf/app/api.app.config
sed -i "s/DB_PASS=.*/DB_PASS=${DB_PASS:-kasmdb_password}/" /opt/kasm/current/conf/app/api.app.config
sed -i "s/DB_PORT=.*/DB_PORT=${DB_PORT:-5432}/" /opt/kasm/current/conf/app/api.app.config

# Configure public IP
sed -i "s/PUBLIC_IP=.*/PUBLIC_IP=${PUBLIC_IP:-127.0.0.1}/" /opt/kasm/current/conf/app/api.app.config

# Start Kasm services
/opt/kasm/bin/start

# Keep container running
tail -f /dev/null
