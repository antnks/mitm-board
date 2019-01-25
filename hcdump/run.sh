#!/bin/bash
#
# Start hcxdumptool on boot
# $1 param - working directory
#

USERDIR=$1
WLAN=wlan0
CAPTURETIME=300

source $USERDIR/config.txt
cd $USERDIR

service network-manager stop
killall wpa_supplicant
killall dhclient

stamp=`date +%Y%m%d-%H%M%S`
file=hcapture-$stamp.pcap

# start capture
echo "default-on" > /sys/class/leds/orangepi\:red\:status/trigger
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger

hcxdumptool -i $WLAN -o $file &
sleep $CAPTURETIME
killall -w hcxdumptool

# idle
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger
echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger

#shutdown -h now

