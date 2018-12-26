#!/bin/bash
#
# Start capture on boot and upload the result to sftp server
# $1 param - working directory
#

USERDIR=$1
GPGID=00112233
SFTPSRV=remoteserver
SFTPCREDS=username,password
CAPTURETIME=300
GPIOPIN=9

source $USERDIR/config.txt
cd $USERDIR

gpio mode $GPIOPIN in

service network-manager stop
brctl addbr br0
brctl addif br0 eth0
brctl addif br0 enx00606e014ab1
ifconfig br0 0.0.0.0 up

stamp=`date +%Y%m%d-%H%M%S`
file=capture-$stamp.pcap

# start capture
echo "default-on" > /sys/class/leds/orangepi\:red\:status/trigger
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger

tcpdump -i br0 -s 0 -w $file &
sleep $CAPTURETIME
killall -w tcpdump

# start upload
echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger
echo "heartbeat" > /sys/class/leds/orangepi\:green\:pwr/trigger

# check input pin for silent mode
# if jumper is set - bridge will request DHCP and upload
pinstatus=`gpio read 9`
if [ "$pinstatus" == 0 ]
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

#shutdown -h now

