#!/bin/bash

WAN=eth0
VPN=tun0

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING --out-interface $WAN -j MASQUERADE
iptables --append FORWARD --in-interface $VPN -j ACCEPT
