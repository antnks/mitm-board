#!/bin/bash

# disable systemd-resolved
# rm /etc/resolv.conf
# echo nameserver 1.1.1.1 > /etc/resolv.conf

ip link add dev wg0 type wireguard
ip addr add 10.0.0.2/24 dev wg0
ip link set dev wg0 mtu 1440
wg setconf wg0 wg2.conf
ip link set wg0 up

ip addr
wg show

gw=`route -n | grep "^0.0.0.0" | awk '{ print $2 }'`
ip route add 1.2.3.4/32 via "$gw"
ip route flush 0/0
ip route add default via 10.0.0.1

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING --out-interface wg0 -j MASQUERADE
iptables --append FORWARD --in-interface wlp4s0 -j ACCEPT

ip addr add 192.168.0.1/24 dev wlp4s0
ip link set up dev wlp4s0
hostapd hostapd.conf -B
dnsmasq -C dnsmasq.conf

UDPspeeder/speederv2 -c -l 0.0.0.0:12345 -r 1.2.3.4:12345 --mode 1 --mtu 1500 &

