#!/bin/bash
set +x
#Initial wifi interface configuration
ifconfig $1 up 192.168.2.1 netmask 255.255.255.0
sleep 2

# start dhcp
sudo service dnsmasq restart

#Enable NAT
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
iptables --table nat --append POSTROUTING --out-interface $2 -j MASQUERADE
iptables --append FORWARD --in-interface $1 -j ACCEPT
 
#Thanks to lorenzo
#Uncomment the line below if facing problems while sharing PPPoE, see lorenzo's comment for more details
#iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
 
sysctl -w net.ipv4.ip_forward=1
#start hostapd
hostapd /etc/hostapd/hostapd.conf 1> /dev/null &
