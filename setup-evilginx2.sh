#!/bin/bash
set -e

# This script will be executed in the Kasm workspace for evilginx2 setup

echo "[+] Setting up Evilginx2 environment in Kasm workspace..."

# Install dependencies
sudo apt-get update
sudo apt-get install -y git make golang-go ca-certificates dnsutils

# Create workspace data directory if it doesn't exist
mkdir -p /home/kasm-user/data
cd /home/kasm-user/data

# Clone evilginx2 if not already present
if [ ! -d "evilginx2" ]; then
    echo "[+] Cloning evilginx2 repository..."
    git clone https://github.com/kgretzky/evilginx2.git
    cd evilginx2
else
    echo "[+] Evilginx2 already cloned, updating..."
    cd evilginx2
    git pull
fi

# Build evilginx2
echo "[+] Building evilginx2..."
go mod download
go build -o evilginx2 .

# Create necessary directories for persistent storage
mkdir -p /home/kasm-user/data/evilginx2_config
mkdir -p /home/kasm-user/data/evilginx2_redirectors

# Create a desktop shortcut
cat > /home/kasm-user/Desktop/Evilginx2.desktop << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Evilginx2
Comment=Evilginx2 Phishing Framework
Exec=gnome-terminal -- bash -c "cd /home/kasm-user/data/evilginx2 && sudo ./evilginx2 -p ./phishlets; exec bash"
Icon=utilities-terminal
Terminal=false
StartupNotify=true
EOF

chmod +x /home/kasm-user/Desktop/Evilginx2.desktop

# Create a README file with usage instructions
cat > /home/kasm-user/Desktop/Evilginx2-README.txt << EOF
Evilginx2 Usage Instructions:

1. Start Evilginx2 by double-clicking the desktop shortcut or run:
   cd /home/kasm-user/data/evilginx2 && sudo ./evilginx2 -p ./phishlets

2. Basic commands:
   - phishlets - List available phishlets
   - phishlets enable <phishlet> - Enable a phishlet
   - lures create <phishlet> - Create a lure for a phishlet
   - lures get-url <id> - Get the URL for a lure
   - sessions - List active sessions
   - sessions <id> - View details of a session

3. For more information, visit: https://help.evilginx.com/

Note: Evilginx2 requires root privileges to run properly.
EOF

# Setup firewall rules (assuming UFW is available)
sudo apt-get install -y ufw
sudo ufw allow 53/udp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

echo "[+] Evilginx2 setup complete!"
echo "[+] To start Evilginx2, double-click the desktop shortcut or run: cd /home/kasm-user/data/evilginx2 && sudo ./evilginx2 -p ./phishlets"
echo "[+] See the README file on the desktop for usage instructions."
