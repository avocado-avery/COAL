#!/usr/bin/env bash
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="$ID"
    fi
}



detect_os
case "$OS" in
    ubuntu|debian|mint)
        apt-get install --reinstall -o Dpkg::Options::="--force-confask,confnew,confmiss" $(dpkg -S /etc/pam.d/\* | cut -d: -f1)
        apt-get install --reinstall -y libpam-modules
        ;;
    rhel|fedora|centos|rocky)
    packages=$(find /etc/pam.d/ -type f | xargs -I{} rpm -qf {} | sort -u)
        if [ -n "$packages" ]; then
            yum reinstall -y $packages
        fi
        ;;
    *)
        echo "unsupported OS"
        exit 1
esac

echo "Pam reinstalled and cleaned on $OS"
