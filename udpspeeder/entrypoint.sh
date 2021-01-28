#!/bin/bash

ip link add dev wg0 type wireguard
ip addr add 10.0.0.1/24 dev wg0
ip link set dev wg0 mtu 1440
wg setconf wg0 /app/wg1.conf
ip link set wg0 up

ip addr
wg show

iptables -t nat -A POSTROUTING --out-interface eth0 -j MASQUERADE
iptables -A FORWARD --in-interface wg0 -j ACCEPT

/UDPspeeder/speederv2 -s -l 0.0.0.0:$UPORT -r 127.0.0.1:$WPORT --mode 1 --mtu 1500

