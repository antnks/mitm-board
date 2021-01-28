#!/bin/bash

sudo docker run --cap-add=NET_ADMIN --cap-add=SYS_MODULE --device /dev/net/tun \
		-e "UPORT=12345" -e "RPORT=12345" -e "WPORT=51820" -e "REMOTE=1.2.3.4" \
		-p 12345:12345/udp \
		-v "/root/app:/app" -ti udpspeeder


