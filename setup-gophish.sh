#!/bin/bash
set -e

# This script will be executed in the Kasm workspace for Gophish setup

echo "[+] Setting up Gophish environment in Kasm workspace..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y git make golang-go ca-certificates nodejs npm

# Create workspace data directory if it doesn't exist
mkdir -p /home/kasm-user/data
cd /home/kasm-user/data

# Clone gophish if not already present
if [ ! -d "gophish" ]; then
    echo "[+] Cloning gophish repository..."
    git clone https://github.com/gophish/gophish.git
    cd gophish
else
    echo "[+] Gophish already cloned, updating..."
    cd gophish
    git pull
fi

# Install npm dependencies
echo "[+] Installing npm dependencies..."
npm install

# Install gulp globally
echo "[+] Installing gulp..."
sudo npm install -g gulp

# Build the frontend assets
echo "[+] Building frontend assets..."
gulp

# Build the Go binary
echo "[+] Building gophish..."
go mod download
go build -o gophish .

# Create necessary directories for persistent storage
mkdir -p /home/kasm-user/data/gophish_profiles
mkdir -p /home/kasm-user/data/gophish_storage

# Update the config to listen on all interfaces
echo "[+] Updating configuration..."
sed -i 's/127.0.0.1/0.0.0.0/g' config.json

# Create a desktop shortcut
cat > /home/kasm-user/Desktop/Gophish.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Gophish
Comment=Gophish Phishing Framework
Exec=gnome-terminal -- bash -c "cd /home/kasm-user/data/gophish && ./gophish; exec bash"
Icon=utilities-terminal
Terminal=false
StartupNotify=true
EOF

chmod +x /home/kasm-user/Desktop/Gophish.desktop

# Setup firewall rules (assuming UFW is available)
sudo apt-get install -y ufw
sudo ufw allow 3333/tcp  # Admin interface
sudo ufw allow 8080/tcp  # Phishing server
sudo ufw allow 8443/tcp  # Phishing server (HTTPS)
sudo ufw allow 80/tcp    # HTTP redirector

echo "[+] Gophish setup complete!"
echo "[+] Admin interface will be available at https://localhost:3333/"
echo "[+] Default credentials: admin/gophish"
echo "[+] To start Gophish, double-click the desktop shortcut or run: cd /home/kasm-user/data/gophish && ./gophish"
