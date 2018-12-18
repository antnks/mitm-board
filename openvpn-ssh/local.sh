#!/bin/bash

GW=192.168.0.1
VPN=192.168.1.1
VPNPORT=443
VPNLOCALPORT=11111
TUN=192.168.111.1

route add $VPN/32 gw $GW
ip route del 0/0

ssh vpn@$VPN -f -N -L $VPNLOCALPORT:127.0.0.1:$VPNPORT
service openvpn@client start
route add default gw $TUN
