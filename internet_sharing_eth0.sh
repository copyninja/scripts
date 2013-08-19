#!/bin/sh

set -eu

# Restart the dnsmasq
/etc/init.d/dnsmasq restart

# Set nat rules in iptables
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

# Replace accordingly usb0 with ppp0 for 3G
iptables --table nat --append POSTROUTING --out-interface wlan0 -j MASQUERADE
iptables --append FORWARD --in-interface eth0 -j ACCEPT

# Enable IP forwarding in Kernel
sysctl -w net.ipv4.ip_forward=1
