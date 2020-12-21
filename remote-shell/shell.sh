#!/bin/bash
#
# net.ipv6.conf.all.disable_ipv6=1
# net.ipv6.conf.default.disable_ipv6=1
# net.ipv6.conf.lo.disable_ipv6=1

LAN=eth0
WLAN=
IP=
PORT=
REMPORT=

source config.txt

echo "default-on" > /sys/class/leds/orangepi\:red\:status/trigger

service network-manager stop
killall -w wpa_supplicant
killall dnsmasq
rfkill unblock wlan

wpa_supplicant -D wext -i "$WLAN" -c wpa.conf &

sleep 10

iptables -I INPUT -s 0.0.0.0/0 -j DROP
iptables -I INPUT -p udp -i "$WLAN" --dport 67 -j ACCEPT
iptables -I INPUT -s "$IP" -j ACCEPT
iptables -I INPUT -s 127.0.0.1 -j ACCEPT

dhclient "$WLAN"

sleep 10

echo "heartbeat" > /sys/class/leds/orangepi\:red\:status/trigger

while true
do
	ssh "shell@$IP" -p "$PORT" \
	-o HostKeyAlgorithms=ecdsa-sha2-nistp256 -o FingerprintHash=sha256 \
	-o ServerAliveInterval=60 -o ConnectTimeout=10 \
	-i shell.pem -R "$REMPORT:127.0.0.1:22" -N
	echo "Retry.."
	sleep 10
done &

