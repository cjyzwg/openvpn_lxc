#!/bin/sh
stopfile="stop_vpn_nsq.sh"
lxcname=$1
# read -p "请输入对应的lxc容器名称: " lxcname
echo $lxcname
lxc file push /root/openvpn/$stopfile $lxcname/root/
lxc exec $lxcname -- bash -c "/root/$stopfile "


