#!/bin/bash

JSON_FILE="/root/Develop/COAL/coordinate-root/config.json"
LOCAL_FILE="/root/.ssh/id_rsa_temp.pub"
REMOTE_PATH="/root/.ssh/id_rsa_temp.pub"

# Ensure jq is installed (used for parsing JSON)
if ! command -v jq &> /dev/null; then
    echo "[!] jq is not installed. Install it using: sudo apt install jq (Debian/Ubuntu) or sudo yum install jq (RHEL)"
    exit 1
fi

# Parse JSON and iterate over each server
jq -c '.[]' "$JSON_FILE" | while read -r entry; do
    IP=$(echo "$entry" | jq -r '.IP')
    USERNAME=$(echo "$entry" | jq -r '.Username')
    PASSWORD=$(echo "$entry" | jq -r '.Password')

    echo "[+] Transferring file to $USERNAME@$IP..."

    # Using sshpass to provide password non-interactively
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no "$USERNAME@$IP:$REMOTE_PATH" "$LOCAL_FILE"

    if [ $? -eq 0 ]; then
        echo "[+] Successfully transferred file to $IP"
    else
        echo "[!] Failed to transfer file to $IP"
    fi
done

# Place Remote Hosts Public Key in authorized_keys
cat "/root/.ssh/id_rsa_temp.pub" >> "/root/.ssh/authorized_keys"

