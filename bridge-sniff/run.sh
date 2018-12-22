#!/bin/bash
#
# Start capture on boot and upload the result to sftp server
#

USERDIR=/home/user
GPGID=00112233
SFTPSRV=remoteserver
SFTPCREDS=username,password

cd $USERDIR

stamp=`date +%Y%m%d-%H%M%S`
file=capture-$stamp.pcap
capturetime=300

# start capture
echo "default-on" > /sys/class/leds/orangepi\:red\:status/trigger
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger

tcpdump -i br0 -s 0 -w $file &
sleep $capturetime
killall -w tcpdump

# start upload
echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger
echo "heartbeat" > /sys/class/leds/orangepi\:green\:pwr/trigger

gzip $file
gpg --encrypt -r $GPGID $file.gz
lftp -e "set net:timeout 30; set net:max-retries 1; set ftp:ssl-auth TLS; put $file.gz.gpg; bye" $SFTPSRV -u $SFTPCREDS

sync

# idle
echo "default-on" > /sys/class/leds/orangepi\:green\:pwr/trigger
echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger

#shutdown -h now

