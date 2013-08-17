#!/bin/zsh

# Bring up the wlan0 interface
ifconfig wlan0 up

# Put the interface in Ad-hoc mode
iwconfig wlan0 mode Ad-hoc

# Set the essid for the access point
iwconfig wlan0 essid copyninja

# Set auto channel
iwconfig wlan0 channel auto

# Set the security (WEP)

# Set encryption
iwconfig wlan0 key on

# Set Key
iwconfig wlan0 key restricted 9886-3415-80

# bring up the lan and assign IP address
ifconfig wlan0 up 192.168.1.1 netmask 255.255.255.0

# Restart the dnsmasq
/etc/init.d/dnsmasq restart

# Set nat rules in iptables
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain

# Replace accordingly usb0 with ppp0 for 3G
iptables --table nat --append POSTROUTING --out-interface ppp0 -j MASQUERADE
iptables --append FORWARD --in-interface wlan1 -j ACCEPT

# Enable IP forwarding in Kernel
sysctl -w net.ipv4.ip_forward=1
