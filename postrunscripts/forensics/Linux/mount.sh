#!/bin/bash

LOCAL_HOST_IP="10.60.125.22"
LOCAL_USER="root"
REMOTE_DIR="/root/HOSTS"
LOCAL_MOUNT_DIR="/root/HOSTS"
PUB_KEY_FILE="id_rsa_temp.pub"

# Move to the Remote HOSTS directory
cd "$REMOTE_DIR" || { echo "Directory $REMOTE_DIR not found!";mkdir -p "/root/HOSTS"; exit 1; }
cd "/"

# Check for the presence of a public key to Local
if [[ -f "/root/.ssh/$PUB_KEY_FILE" ]]; then
  echo "[+] Public Key found on $(hostname)."
  # Mount via SSHFS w/o password
  sshfs -o ssh_command='ssh -o IdentityFile=/root/.ssh/id_rsa_temp' root@$LOCAL_HOST_IP:/root/HOSTS /root/HOSTS
else
  echo "[!] No Public Key found on $(hostname)."
fi

echo "Mounted on: $(mount | grep root)"
