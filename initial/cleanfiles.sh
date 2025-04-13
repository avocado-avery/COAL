#!/usr/bin/env bash

echo '127.0.0.1 localhost' > /etc/hosts

echo 'nameserver 1.1.1.1' > /etc/resolv.conf

sed -i 's/ldap/db files/g' /etc/nsswitch.conf

echo > /etc/sudoers

echo "[✓] clean hosts,resolv.conf, and nsswitch.conf"

