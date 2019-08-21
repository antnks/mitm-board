#!/bin/bash
#
# starts a hotspot
# $1 param is working dir
#

USERDIR=$1

DNSMASQSUBNET="192.168.1"
HOSTAPIF="wlan0"
HOSTAPSSID="mitm"
HOSTAPPSW="nastymitm!11"

source $USERDIR/config.txt
cd $USERDIR/hotspot/

DNSMASQRANGE="$DNSMASQSUBNET.50,$DNSMASQSUBNET.150"
DNSMASQRESP="$DNSMASQSUBNET.2"
HOSTAPIP="$DNSMASQSUBNET.1"

service network-manager stop
killall -w hostapd
killall -w dnsmasq
killall -w wpa_supplicant

sed "s/interface=.*/interface=$HOSTAPIF/g" -i hostapd.conf
sed "s/wpa_passphrase=.*/wpa_passphrase=$HOSTAPPSW/g" -i hostapd.conf
sed "s/ssid=.*/ssid=$HOSTAPSSID/g" -i hostapd.conf
sed "s/interface=.*/interface=$HOSTIF/g" -i dnsmasq.conf
sed "s/address=.*/address=\/#\/$DNSMASQRESP/g" -i dnsmasq.conf
sed "s/dhcp-range=.*/dhcp-range=$DNSMASQRANGE.50,$DNSMASQRANGE.150,12h/g" -i dnsmasq.conf

ifconfig $HOSTAPIF $HOSTAPIP up
hostapd hostapd.conf &
dnsmasq -C dnsmasq.conf

