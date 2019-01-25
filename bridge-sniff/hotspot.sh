# starts a hotspot
# $1 param is working dir

USERDIR=$1
WLAN=wlan0

source $USERDIR/config.txt
cd $USERDIR

killall -w hostapd
killall -w dnsmasq
killall -w wpa_supplicant

ifconfig $WLAN 192.168.1.1 up
hostapd hostapd.conf &
dnsmasq -C dnsmasq.conf

