#! /bin/sh
VPN=$(pgrep openvpn)
if [ -z "$VPN" ]
then
    echo "no openvpn found"
else
    kill -9 $VPN
fi
NSQ=$(pgrep nsq)
if [ -z "$NSQ" ]
then
    echo "no nsq found"
else
    kill -9 $NSQ
fi