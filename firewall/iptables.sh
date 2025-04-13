#!/usr/bin/env bash



cat <<'EOF' > firewallrules.sh
#!/usr/bin/env bash

#modprobe ip_conntrack_ftp
#echo "net.netfilter.nf_conntrack_helper=1" >> /etc/sysctl.conf
#sysctl -p


I() { iptables "$@"; }
I -P INPUT ACCEPT; I -P OUTPUT ACCEPT; I -P FORWARD ACCEPT
I -F; I -X
I -P INPUT DROP; I -P OUTPUT DROP; I -P FORWARD DROP
I -A INPUT  -i lo -j ACCEPT
I -A OUTPUT -o lo -j ACCEPT


# Ping IN/OUT
# I -A INPUT -p icmp -j ACCEPT
# I -A OUTPUT -p icmp -j ACCEPT

# IN
I -A INPUT  -p tcp -m multiport --dports 22,80,x,y -j ACCEPT


# OUT
I -A OUTPUT -p tcp -m multiport --dports 80,443,8000,9997 -j ACCEPT

# DNS
I -A OUTPUT -p udp --dport 53 -j ACCEPT

# Established Related
I -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
I -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT


conntrack -F
EOF

chmod +x firewallrules.sh
