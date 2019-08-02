Use jumpers to control the mode:

![orangepi-zero-mitm-schematics.png](orangepi-zero-mitm-schematics.png)


JUMPER 1 (GPIO 11, WiringPi 9): on/off

Not set (removed): will boot, but not start any script

Set: will run script on start up


JUMPER 2 (GPIO 19, WiringPi 4): mode

Not set (removed): bridge sniff mode

Set: hcdump mode


JUMPER 3 (GPIO 18, WiringPi 5): capture upload

Not set (removed): will not try to upload the capture

Set: will get IP from DHCP and upload the capture file
