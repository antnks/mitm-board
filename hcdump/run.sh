#!/bin/bash
#
# Start hcxdumptool on boot
# $1 param - working directory
#

USERDIR=$1

WLAN=wlan0
HCAPTURETIME=300
SHUTDOWN=0

source $USERDIR/config.txt
cd $USERDIR/hcdump

service network-manager stop
killall wpa_supplicant
killall dhclient

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
