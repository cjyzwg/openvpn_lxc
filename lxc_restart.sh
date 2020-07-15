#!/bin/sh
#./opevpn/lxc_reconnect_internet.sh
#用作比较的nsq 只放一个主nsqlookupd server
CONTAINERNAME=$2
# CONTAINERNAME="s1"
NSQFOLDER="/root/nsq1.2"
# read -p "请输入对应的lxc容器名称: " lxcname
lxcname=$1
# echo $lxcname
if [ -n "$NSQ" ]; then 
    echo "容器$lxcname 不存在"
    exit 1;
fi
if [ ! -f "/root/$lxcname.ovpn" ]; then 
    echo "$lxcname.ovpn 不存在,请用openinstall.sh 添加新用户"
    exit 1;
fi
OPENVPN=`lxc exec $lxcname pgrep openvpn`       
if [ -n "$OPENVPN" ];then  
    echo "openvpn service is running"
else
    echo "openvpn service is not running,ok then can do this"
    lxc file push /root/$lxcname.ovpn $lxcname/root/
    lxc exec $lxcname  -- sh -c "apt-get install -y openvpn"
    # lxc exec test -- nohup bash -c "/root/test.sh &"
    # lxc exec $lxcname -- sh -c "nohup openvpn --config /root/$lxcname.ovpn &" #不生效
    lxc exec $lxcname -- nohup bash -c " openvpn --config /root/$lxcname.ovpn &"
fi
echo "等待5s openvpn启动"
sleep 5

lookupdip=`lxc exec ${CONTAINERNAME} ifconfig tun0 | grep "inet addr:" | awk '{print $2}' | cut -c 6-` 
echo "lookupdip openvpn ip is : $lookupdip"
NSQ=`lxc exec $lxcname pgrep nsq`       
if [ -n "$NSQ" ]; then 
        echo "nsq service is running"
        exit 1;
    else
        echo "nsq service is not running,we can do this;"
        lxc file push /root/nsq-1.2.0.linux-amd64.go1.12.9.tar.gz $lxcname/root/
        lxc exec $lxcname -- sh -c "tar -zxvf /root/nsq-1.2.0.linux-amd64.go1.12.9.tar.gz" 
        lxc exec $lxcname -- sh -c "rm -rf ${NSQFOLDER}"
        lxc exec $lxcname -- sh -c "mv /root/nsq-1.2.0.linux-amd64.go1.12.9 ${NSQFOLDER}"
        if [ $lxcname = ${CONTAINERNAME} ];then 
            echo "xxxx"
            #lxc exec s1 -- nohup bash -c "/root/nsq1.2/bin/nsqlookupd &"
            lxc exec $lxcname -- nohup bash -c "/${NSQFOLDER}/bin/nsqlookupd &"
            lxc exec $lxcname -- nohup bash -c "/${NSQFOLDER}/bin/nsqd --lookupd-tcp-address=127.0.0.1:4160 &"
            lxc exec $lxcname -- nohup bash -c "/${NSQFOLDER}/bin/nsqadmin --lookupd-http-address=127.0.0.1:4161 &"
        else
            lxc exec $lxcname -- nohup bash -c "/${NSQFOLDER}/bin/nsqd --lookupd-tcp-address=$lookupdip:4160 &"
        fi
fi




