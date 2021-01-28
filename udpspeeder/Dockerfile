FROM ubuntu:focal
RUN apt-get update
RUN apt install -y wget curl inetutils-ping iproute2 net-tools openssh-server iptables
RUN apt-get install -y wireguard wireguard-tools
RUN apt-get install -y git build-essential

RUN git clone https://github.com/wangyu-/UDPspeeder ; cd UDPspeeder ; make

ENTRYPOINT /app/entrypoint.sh

