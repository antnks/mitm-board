#!/bin/bash

sudo add-apt-repository universe
sudo add-apt-repository multiverse
sudo apt-get update

sudo apt-get install git make vim gddrescue
sudo apt0get install bridge-utils net-tools hostapd openvpn wireshark

sudo apt-get install default-jre
wget "https://portswigger.net/burp/releases/download?product=community&version=1.7.36&type=jar&componentid=100" -O burp.jar

