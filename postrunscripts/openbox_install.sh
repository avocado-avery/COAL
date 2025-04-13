#!/usr/bin/env bash

# GUI installation script
# ps aux | grep yum/apt to check if downloads are complete
echo "run startx for gui after installation is complete"
# script to detect the OS
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="$ID"
    fi

# Check if gui already installed
if [[ -n "$DISPLAY" || -n "$WAYLAND_DISPLAY" ]]; then
    echo "A GUI is already running. Exiting script."
    exit 0
fi

# Install necessary packages for openbox
    case "$OS" in
        debian|mint)
            echo "Installing obenbox for $OS"
            apt-get update -qq > /dev/null;
	    export DEBIAN_FRONTEND=noninteractive
            apt-get install -y -qq openbox xinit firefox-esr xfce4-terminal > /dev/null;
            ;;
    	ubuntu)
	echo "Installing openbox for "$OS""
	apt-get update -qq > /dev/null;
	export DEBIAN_FRONTEND=noninteractive
	apt-get install -y -qq openbox xinit firefox xfce4-terminal > /dev/null;
	    ;;
        rhel|centos|fedora|rocky|amzn)
            echo "Installing openbox for $OS"
	    yum update -y
            yum install -y openbox xinit firefox xfce4-terminal Xorg > /dev/null;
            ;;
        *)
            echo "Unsupported OS for openbox installation"
            exit 1
            ;;
    esac

echo "exec openbox-session" > ~/.xinitrc





