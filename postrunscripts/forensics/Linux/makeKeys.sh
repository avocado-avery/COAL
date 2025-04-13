#!/bin/bash

# Create temporary SSH keys for the Remote Hosts to use

# Set custom directory for SSH keys
KEY_DIR="/root/HOSTS"
KEY_NAME="id_rsa_temp"
KEY_PATH="$KEY_DIR/$KEY_NAME"

# Ensure the directory exists
mkdir -p "$KEY_DIR"

# Check if the SSH key already exists
if [ -f "$KEY_PATH" ] && [ -f "$KEY_PATH.pub" ]; then
    echo "[+] SSH keys already exist at: $KEY_PATH"
    echo "[+] Removing SSH keys."
    rm -rf "$KEY_PATH/$KEY_NAME"
    rm -rf "$KEY_PATH/$KEY_NAME.pub"
fi
# Generate SSH key pair (no passphrase)
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""
echo "[+] New SSH keys generated and stored in: $KEY_DIR"

# Set proper permissions
chmod 700 "$KEY_DIR"
chmod 600 "$KEY_PATH"
chmod 644 "$KEY_PATH.pub"
mv "$KEY_PATH" "/root/.ssh/"
mv "$KEY_PATH.pub" "/root/.ssh/"
echo "[+] SSH key setup complete."
