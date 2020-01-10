#!/bin/bash
#
# Start hcxdumptool on boot
# $1 param - working directory
#

USERDIR=$1

source $USERDIR/config.txt
if [ -z "$DNSMASQSUBNET" ]
then
	echo "Cannot source the configuartion"
	exit 1
fi

cd $USERDIR/hcdump/

service network-manager stop
killall -w hostapd
killall -w dnsmasq
killall -w wpa_supplicant
rfkill unblock wlan

WLAN=$HOSTAPIF

stamp=`date +%Y%m%d-%H%M%S`
file=hcapture-$stamp.pcap

# start capture
echo "default-on" > /sys/class/leds/orangepi\:red\:status/trigger
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger

hcxdumptool -i $WLAN -o $file &
sleep $HCAPTURETIME
killall -w hcxdumptool

# idle
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger
echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger

# shutdown when finished
if [ "$SHUTDOWN" != "0" ]
then
	shutdown -h now
fi

