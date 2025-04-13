#!/usr/bin/env bash

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS="$ID"
    fi
}

install_packages() {
    detect_os

    case "$OS" in
        ubuntu|debian|mint)
            export DEBIAN_FRONTEND=noninteractive
            apt-get -o DPkg::Lock::Timeout=-1 -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install -qq -y "$@"
            ;;
        rhel|centos|fedora|rocky)
            yum install -y "$@"
            ;;
        *)
            echo "Unsupported OS"
            exit 1
            ;;
    esac
}

detect_os

case "$OS" in
    ubuntu|debian|mint)
        install_packages conntrack iptables iptables-persistent vim net-tools
        ;;
    rhel|centos|fedora|rocky)
        install_packages conntrack-tools iptables iptables-services vim net-tools
        ;;
    *)
        echo "Unsupported OS"
        exit 1
        ;;
esac &

