#!/bin/bash

# Splunk Server Installation Script
# This script downloads the Splunk package to the current working directory (if not already present)
# and installs it. It expects either:
#   - splunk.deb (for Debian-based distributions) OR
#   - splunk.rpm (for RHEL/Fedora-based distributions)
#
# Usage: sudo bash splunkserver.sh <admin_password>

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root." >&2
    exit 1
fi

# Check that admin password is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <admin_password>"
    exit 1
fi

# Hard-coded download URLs for Splunk 9.3.3
DEB_URL="https://download.splunk.com/products/splunk/releases/9.3.3/linux/splunk-9.3.3-75595d8f83ef-linux-2.6-amd64.deb"
RPM_URL="https://download.splunk.com/products/splunk/releases/9.3.3/linux/splunk-9.3.3-75595d8f83ef.x86_64.rpm"

# Determine OS type and select package filename and URL
detect_os_and_set_package() {
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            debian|ubuntu|kali|pop|linuxmint|elementary|parrot)
                PACKAGE_FILE="splunk.deb"
                DOWNLOAD_URL="$DEB_URL"
                ;;
            centos|rhel|rocky|almalinux|fedora|opensuse|sles)
                PACKAGE_FILE="splunk.rpm"
                DOWNLOAD_URL="$RPM_URL"
                ;;
            *)
                echo "Unsupported OS: $ID. Exiting." >&2
                exit 1
                ;;
        esac
    else
        echo "Unable to determine OS type. Exiting." >&2
        exit 1
    fi
}

# Download the package file to the current working directory if it's missing
download_package_if_missing() {
    if [[ -f "$PACKAGE_FILE" ]]; then
        echo "Package file '$PACKAGE_FILE' found in current directory. Skipping download."
    else
        echo "Downloading Splunk package from $DOWNLOAD_URL ..."
        # Prefer wget if available, else try curl
        if command -v wget >/dev/null 2>&1; then
            wget -O "$PACKAGE_FILE" "$DOWNLOAD_URL"
        elif command -v curl >/dev/null 2>&1; then
            curl -L -o "$PACKAGE_FILE" "$DOWNLOAD_URL"
        else
            echo "Error: Neither wget nor curl is installed. Please install one to download files." >&2
            exit 1
        fi

        if [[ ! -f "$PACKAGE_FILE" ]]; then
            echo "Error: Failed to download package." >&2
            exit 1
        fi
        echo "Downloaded file saved as '$PACKAGE_FILE'."
    fi
}

# Install the package using the appropriate package management tool
install_package() {
    if [[ ! -f "$PACKAGE_FILE" ]]; then
        echo "Package file '$PACKAGE_FILE' not found in the current directory." >&2
        exit 1
    fi

    echo "Installing package file '$PACKAGE_FILE'..."
    if [[ -f /etc/os-release ]]; then
        source /etc/os-release
        case "$ID" in
            debian|ubuntu|kali|pop|linuxmint|elementary|parrot)
                dpkg -i "$PACKAGE_FILE"
                ;;
            centos|rhel|rocky|almalinux|fedora)
                rpm -ivh "$PACKAGE_FILE"
                ;;
            opensuse|sles)
                zypper install -y "$PACKAGE_FILE"
                ;;
            *)
                echo "Unsupported OS: $ID" >&2
                exit 1
                ;;
        esac
    else
        echo "OS detection error." >&2
        exit 1
    fi
}

# Create necessary Splunk directories if they don't exist
create_splunk_directories() {
    if [[ ! -d /opt/splunk/etc/system/local ]]; then
        mkdir -p /opt/splunk/etc/system/local
    fi
}

# Main execution flow
echo "Starting Splunk server installation..."

# Determine OS and select package file and download URL
detect_os_and_set_package
echo "Detected OS. Package file to use: $PACKAGE_FILE"

# Download the package if it is not already in the current working directory
download_package_if_missing

# Install the package from the current working directory
install_package

# Ensure configuration directories exist
create_splunk_directories

# Enable Splunk to start on boot
/opt/splunk/bin/splunk enable boot-start --no-prompt --accept-license

# Hide the first-time login message (if not already hidden)
touch /opt/splunk/etc/.ui_login

# Set admin credentials
echo "[user_info]
USERNAME = admin
PASSWORD = $1" > /opt/splunk/etc/system/local/user-seed.conf

# Add custom indexes
/opt/splunk/bin/splunk add index linux
/opt/splunk/bin/splunk add index windows
/opt/splunk/bin/splunk add index networking

# Configure inputs: listeners and file monitors
echo "[splunktcp://9997]
disabled = 0
  
[udp://514]
connection_host = ip
sourcetype = syslog
index = networking

[tcp://514]
connection_host = dns
sourcetype = syslog
index = networking

[tcp://5514]
connection_host = ip
sourcetype = pan:firewall
index = networking

[monitor:///var/log]
disabled = false
blacklist = (/var/log/dpkg\.log|/var/log/clamav/clamav\.log|/var/log/bootstrap\.log|/var/log/clamav/freshclam\.log)
sourcetype = syslog

[monitor:///var/log/apache2]
disabled = false
sourcetype = access_combined

[monitor:///var/log/mail.log]
disabled = false
sourcetype = postfix_syslog

[monitor:///var/log/named]
disabled = false
sourcetype = querylog

[monitor:///var/log/exim4]
disabled = false
sourcetype = exim_main" > /opt/splunk/etc/system/local/inputs.conf

# Configure disk usage settings
echo "[diskUsage]
minFreeSpace = 500" >> /opt/splunk/etc/system/local/server.conf

# Configure the login banner
echo "[settings]
login_content = 'You are accessing a restricted information system. Unauthorized access is prohibited and will be prosecuted to the full extent of the law.'" > /opt/splunk/etc/system/local/web.conf

# Stop any running Splunk forwarder processes (ignore errors if not found)
killall -9 splunkd 2>/dev/null
systemctl disable --now SplunkForwarder 2>/dev/null

# Start Splunk non-interactively
/opt/splunk/bin/splunk start --no-prompt --accept-license

# Adjust ownership if the 'splunk' user exists
if id splunk &>/dev/null; then
    chown -R splunk:splunk /opt/splunk
else
    echo "Warning: 'splunk' user not found. Skipping chown step."
fi

echo "Splunk server installation completed."
