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

command_exists() {
  command -v "$1" > /dev/null 2>&1
}

# System Information
HOSTNAME=$(hostname || cat /etc/hostname)
IP_ADDR=$(hostname -I | awk '{print $1}')
OS=$(cat /etc/os-release | grep "PRETTY_NAME" | cut -d= -f2 | tr -d '"')
UNAME=$(uname -a)
empty_line
echo -e "$HOSTNAME Summary"
sep

printf "Hostname: %s\n" "$HOSTNAME"
printf "IP Address: %s\n" "$IP_ADDR"
printf "Operating System: %s\n" "$OS"
sep

# Network Information
echo "Open Ports and Services:"
dash_sep
if command_exists ss; then
    ss -tulpn | awk 'NR==1; NR>1{print | "sort -k 4,4"}'
elif command_exists netstat; then
    netstat -tulpn | grep LISTEN
elif command_exists lsof; then
    lsof -i -P -n | grep LISTEN
else
    echo "Required tools for this section not found"
fi
sep

# User and Group Information
echo "Privileged Users:"
dash_sep
priv_users=$(awk -F: '{if (($3 == 0) || ($3 >= 1000 && $1 != "nobody")) printf "User: %-15s UID: %-5s Home: %-20s Shell: %s\n", $1, $3, $6, $7}' /etc/passwd)
echo "$priv_users"
sep

