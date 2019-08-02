# starts a hotspot
# $1 param is working dir

USERDIR=$1

HOSTIF=wlan0

source $USERDIR/config.txt
cd $USERDIR/bridge-sniff

killall -w hostapd
killall -w dnsmasq
killall -w wpa_supplicant

sed "s/interface=.*/interface=$HOSTIF/g" -i hostapd.conf
sed "s/interface=.*/interface=$HOSTIF/g" -i dnsmasq.conf

ifconfig $HOSTIF 192.168.1.1 up
hostapd hostapd.conf &
dnsmasq -C dnsmasq.conf
