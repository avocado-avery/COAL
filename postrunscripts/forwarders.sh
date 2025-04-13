#!/bin/bash

# Script to install Splunk Forwarder (v9.3.3)
# Hardcoded download links
DEB_URL="https://download.splunk.com/products/universalforwarder/releases/9.3.3/linux/splunkforwarder-9.3.3-75595d8f83ef-linux-2.6-amd64.deb"
RPM_URL="https://download.splunk.com/products/universalforwarder/releases/9.3.3/linux/splunkforwarder-9.3.3-75595d8f83ef.x86_64.rpm"

# Ensure it is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

# Ensure log server IP argument is provided
if [[ -z "$1" ]]; then
    echo "Usage: $0 <log_server_ip>"
    exit 1
fi

LOG_SERVER="$1"

# Determine OS type and download appropriate package
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    case "$ID" in
        debian|ubuntu|kali|pop|linuxmint|elementary|parrot)
            wget -O splunkforwarder.deb "$DEB_URL"
            dpkg -i splunkforwarder.deb
            ;;
        centos|rhel|rocky|almalinux|fedora|opensuse|sles)
            wget -O splunkforwarder.rpm "$RPM_URL"
            rpm -ivh splunkforwarder.rpm
            ;;
        *)
            echo "Unsupported OS: $ID"
            exit 1
            ;;
    esac
else
    echo "Could not detect OS."
    exit 1
fi

# Set random Splunk admin password
splunk_forwarder_password=$(cat /dev/urandom | tr -dc 'A-Za-z0-9' | head -c 32)

# Create /usr/bin/splunk helper script
cat <<EOF > /usr/bin/splunk
#!/bin/bash
if [[ "\$1" =~ ^(start|stop|restart|enable)\$ ]]; then
    /opt/splunkforwarder/bin/splunk "\$@"
else
    /opt/splunkforwarder/bin/splunk "\$@" -auth admin:$splunk_forwarder_password --accept-license 2>&1 | grep -i -v warning
fi
EOF

chmod +x /usr/bin/splunk

# Create user-seed.conf with admin password
mkdir -p /opt/splunkforwarder/etc/system/local
echo "[user_info]
USERNAME = admin
PASSWORD = $splunk_forwarder_password" > /opt/splunkforwarder/etc/system/local/user-seed.conf

# Enable Splunk Forwarder on boot
splunk enable boot-start --accept-license

# Configure log forwarding
splunk add forward-server "$LOG_SERVER:9997"
splunk set deploy-poll "$LOG_SERVER:8089"
splunk add monitor /var/log

# Create inputs.conf for log monitoring
mkdir -p /opt/splunkforwarder/etc/apps/search/local
cat <<EOF > /opt/splunkforwarder/etc/apps/search/local/inputs.conf
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
sourcetype = exim_main
EOF

# Start Splunk Forwarder
systemctl start SplunkForwarder

echo "Splunk Forwarder installed and configured."
echo "Admin credentials: admin / $splunk_forwarder_password"

