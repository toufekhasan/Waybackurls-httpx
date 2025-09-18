#!/bin/bash
# ---------------------------------------------------------
# Script Name: auto_install_recon.sh
# Description: Installs Go, configures PATH, installs Waybackurls & httpx,
#              and runs a default recon pipeline.
# Author: Toufe Hasan
# Date: $(date +"%Y-%m-%d")
# ---------------------------------------------------------

set -e

echo "[*] Updating system..."
sudo apt update -y

echo "[*] Checking if Go is installed..."
if command -v go &> /dev/null; then
    echo "[+] Go is already installed. Version:"
    go version
else
    echo "[*] Installing Go..."
    sudo apt install -y golang
fi

# Ensure Go path is set
if ! grep -q "export PATH=\$HOME/go/bin:\$PATH" "$HOME/.bashrc"; then
    echo "[*] Adding Go bin path to ~/.bashrc..."
    echo 'export PATH=$HOME/go/bin:$PATH' >> "$HOME/.bashrc"
fi

if [ -f "$HOME/.zshrc" ] && ! grep -q "export PATH=\$HOME/go/bin:\$PATH" "$HOME/.zshrc"; then
    echo "[*] Adding Go bin path to ~/.zshrc..."
    echo 'export PATH=$HOME/go/bin:$PATH' >> "$HOME/.zshrc"
fi

# Reload shell configuration
source "$HOME/.bashrc" 2>/dev/null || true
source "$HOME/.zshrc" 2>/dev/null || true

# Install Waybackurls
echo "[*] Installing Waybackurls..."
go install github.com/tomnomnom/waybackurls@latest

# Install httpx
echo "[*] Installing httpx..."
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

# Copy binaries to /usr/local/bin
for tool in waybackurls httpx; do
    GOBIN_PATH="$HOME/go/bin/$tool"
    if [ -f "$GOBIN_PATH" ]; then
        echo "[*] Copying $tool binary to /usr/local/bin..."
        sudo cp "$GOBIN_PATH" /usr/local/bin/
        echo "[+] $tool installed successfully!"
    else
        echo "[-] $tool installation failed! Please check Go setup."
    fi
done

# Verify installation
for tool in waybackurls httpx; do
    if command -v $tool &> /dev/null; then
        echo "[+] $tool is ready to use!"
    else
        echo "[-] $tool not found in PATH. Try restarting your terminal."
    fi
done

# Default pipeline command
echo ""
echo "---------------------------------------------------------"
echo "[*] Default example pipeline:"
echo "echo 'example.com' | waybackurls | grep -i '=' | httpx --sc"
echo "---------------------------------------------------------"
echo ""
