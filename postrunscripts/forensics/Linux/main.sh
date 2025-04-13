#!/bin/bash
COAL=$(find / -type d -name 'COAL' -exec bash -c 'for dir; do if [ -d "$dir/coordinate-root" ] && [ -f "$dir/coordinate-root/config.json" ]; then echo "$dir"; fi; done' bash {} +)
coord="$COAL/coordinate-root/coordinate"

# Apt update on Local Host
apt update

# Install dependencies on Local Host
apt install sshfs docker.io docker-compose jq sshpass -y

# Create Local /root/HOSTS
mkdir -p /root/HOSTS

# Create Local /root/HOSTS/Tools
mkdir -p /root/HOSTS/Tools

# Clone UAC to Local /root/HOSTS/Tools
git clone https://github.com/tclahr/uac.git /root/HOSTS/Tools/uac

# Clone Velociraptor Docker to Local /root/HOSTS/Tools
git clone https://github.com/weslambert/velociraptor-docker.git /root/HOSTS/Tools/Velociraptor

# Change directories to cooridinate-root
cd "$COAL/coordinate-root"

# Install Dependencies on Remote Hosts w/ Coordinate
"$coord" -U "$COAL/postrunscripts/forensics/Linux/dependencies.sh"

# Generate the Temporary SSH Keys
"$coord" -U "$COAL/postrunscripts/forensics/Linux/makeKeys.sh"

# Transfer the public key from the Remote Hosts
source "$COAL/postrunscripts/forensics/Linux/transfer.sh"

#Set mount Script IP Address
sed -i "/^LOCAL_HOST_IP=\".*/c\LOCAL_HOST_IP=\"$(hostname -I | awk '{print $1}')\"" "$COAL/postrunscripts/forensics/Linux/mount.sh"

# Mount Remote /root/HOSTS to Local /root/HOSTS
"$coord" -U "$COAL/postrunscripts/forensics/Linux/mount.sh"

