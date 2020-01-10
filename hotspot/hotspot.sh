#!/bin/bash
#
# starts a hotspot
# $1 param is working dir
#

USERDIR=$1

source $USERDIR/config.txt
if [ -z "$DNSMASQSUBNET" ]
then
	echo "Cannot source the configuartion"
	exit 1
fi

cd $USERDIR/hotspot/

DNSMASQRANGE="$DNSMASQSUBNET.50,$DNSMASQSUBNET.150"
DNSMASQRESP="$DNSMASQSUBNET.2"
HOSTAPIP="$DNSMASQSUBNET.1"

service network-manager stop
killall -w hostapd
killall -w dnsmasq
killall -w wpa_supplicant
rfkill unblock wlan

sed "s/interface=.*/interface=$HOSTAPIF/g" -i hostapd.conf
sed "s/wpa_passphrase=.*/wpa_passphrase=$HOSTAPPSW/g" -i hostapd.conf
sed "s/ssid=.*/ssid=$HOSTAPSSID/g" -i hostapd.conf
sed "s/interface=.*/interface=$HOSTAPIF/g" -i dnsmasq.conf
sed "s/address=.*/address=\/#\/$DNSMASQRESP/g" -i dnsmasq.conf
sed "s/dhcp-range=.*/dhcp-range=$DNSMASQRANGE,12h/g" -i dnsmasq.conf

ifconfig $HOSTAPIF $HOSTAPIP up
hostapd hostapd.conf &
dnsmasq -C dnsmasq.conf

