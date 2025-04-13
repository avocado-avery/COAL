#!/usr/bin/env bash

# Utility Functions
sep () {
    echo "======================================================================================================="
}
dash_sep () {
    echo "-------------------------------------------------------------------------------------------------------"
}
empty_line () {
    echo ""
}


FILES=(
    "/etc/shadow"
    "/etc/passwd"
    "/etc/group"
    "/home"
    "/etc/sudoers"
    "/etc/nsswitch.conf"
    "/etc/resolv.conf"
    "/etc/hosts"
)
    
BACKUP_DIR="/bak"
    
SERVICES=(
    "/etc/apache2"
    "/etc/nginx"
    "/etc/mysql"
    "/etc/postgresql"
    "/etc/redis"
    "/etc/mongod.conf"
    "/etc/docker"
    "/var/lib/docker"
    "/etc/libvirt"
    "/var/lib/libvirt"
    "/etc/prometheus"
    "/etc/grafana"
    "/etc/ssh"
    "/home/*/.ssh"
    "/etc/fail2ban"
    "/etc/audit"
    "/etc/php"
    "/var/www/html"
)

    # Create Backup Directory
    if [ ! -d "$BACKUP_DIR" ]; then
        sep
        echo "[Info] Creating Backup Directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR" || { echo "[Error] Failed To Create $BACKUP_DIR Exiting"; exit 1;}
    fi

    # Copy Files
sep
empty_line
echo "[Running Backup] Copying Files to $BACKUP_DIR ..."
empty_line
sep
for ITEM in "${FILES[@]}" "${SERVICES[@]}"; do
    if [ -e "$ITEM" ]; then
        cp -a "$ITEM" "$BACKUP_DIR/" && \
        echo "[Success] Backed up $ITEM to $BACKUP_DIR"
    fi
done


echo "[Backup Completed]"

