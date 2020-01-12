#!/bin/bash
#
# Create a wireless router and redirect the traffic to a transparrent proxy
# Tested using invisible Burp proxy
#

WAN=eth0
LAN=br-lan
ETH=eth1
WLAN=wlan1
WLANIP=192.168.0.10
BURP=192.168.1.2

killall -w wpa_supplicant
killall dnsmasq
rfkill unblock wlan

ifconfig $WLAN 0.0.0.0
ifconfig $ETH 0.0.0.0

iw dev $WLAN set 4addr on

brctl addbr $LAN
brctl addif $LAN $WLAN
brctl addif $LAN $ETH
ifconfig $LAN 192.168.0.1 up

# remove "-s $WLANIP" if you want to redirect all the traffic, not just wireless
iptables -t nat -A PREROUTING -i $LAN -p tcp --dport 80 -s $WLANIP -m conntrack --ctstate NEW -j DNAT --to $BURP:80
iptables -t nat -A PREROUTING -i $LAN -p tcp --dport 22 -s $WLANIP -m conntrack --ctstate NEW -j DNAT --to $BURP:2222
iptables -t nat -A PREROUTING -i $LAN -p tcp --match multiport ! --dports 80,22 -s $WLANIP -m conntrack --ctstate NEW -j DNAT --to $BURP:443
iptables -t nat -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING --out-interface $WAN -j MASQUERADE
iptables --append FORWARD --in-interface $LAN -j ACCEPT

hostapd hostap.conf -B
dnsmasq -C dnsmasq.conf

