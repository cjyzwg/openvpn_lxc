#! /bin/sh
# See how we were called.
#检查容器内网络是否通畅
network()
{
    
    #超时时间
    local timeout=1
    lxcname=$(lxc list|awk ' NR>2 && $2!="" && $2!="|" {print $2}'|awk '{print $0}' | sed -n '$p')
    #目标网站
    local target=www.baidu.com

    #获取响应状态码
    local ret_code=`lxc exec $lxcname -- bash -c "curl -I -s --connect-timeout ${timeout} ${target} -w %{http_code} | tail -n1"`

    if [ "x$ret_code" = "x200" ]; then
        #网络畅通
        return 1
    else
        #网络不畅通
        return 0
    fi

    return 0
}

# awk 'BEGIN { FS=":";print "统计销售金额";total=0} {print NR;total=total+NR;} END {printf "销售金额总计：%.2f",total}' sx
lastnr=$(lxc list|awk ' NR>2 && $2!="" && $2!="|" {print $2}'|awk '{print NR}' | sed -n '$p')
if [ x"$lastnr" != x ];then
    state=$1
    case "$state" in
        start)
            echo "start action is right"
        ;;

        stop)
            echo "stop action is right"
        ;;

        restart|reload|force-reload)
            echo "reload action is right"
        ;;

        *)
            echo "Usage: $0 $lxcname {start|stop|restart|reload|force-reload}"
            exit 2
    esac
    # 检测网络是否正确
    network
    if [ $? -eq 0 ];then
        echo
        echo "容器内网络不畅通，请检查网络设置！"
        echo
        read -p "是否启用 ? [y/N]: " NET
        if [ "$NET" = 'y' -o "$NET" = 'Y' ]; then
            echo "先关闭容器内部网络，可能存在dnsmasq正在运行"
            ./lxc_reconnect_internet.sh  stop
            echo "开启容器内部网络"
            ./lxc_reconnect_internet.sh  start
        else
            exit 1;
        fi
    else
        echo
        echo "容器内网络非常畅通！"
        echo
        read -p "是否关闭 ? [y/N]: " NETSTOP
        if [ "$NETSTOP" = 'y' -o "$NETSTOP" = 'Y' ]; then
            ./lxc_reconnect_internet.sh  stop
        fi
    fi
    echo
    echo "检测过后容器内网络通畅"
    echo
    exitnr=$((lastnr+1))
    echo
    echo "哪一个容器你需要选择开启或关闭 openvpn和nsq?"
    echo
    text=$(lxc list|awk ' NR>2 && $2!="" && $2!="|" {print $2}'|awk '{print NR ")" $0}')
    defaultlxcname=$(lxc list|awk ' NR>2 && $2!="" && $2!="|" {print $2}'|awk '{print $0}'|sed -n "1p")
    echo "0) 所有容器"
    # echo $text #只能在同一行
    echo "$text"
    echo "$exitnr) Exit"
    read -p "Select an option [0-$exitnr]: " nr 
    # echo $nr
    if [ $nr = $exitnr ];then
        echo "退出了"
        exit;
    elif [ $nr = "0" ];then
        for container in $(lxc list|awk ' NR>2 && $2!="" && $2!="|" {print $2}'|awk '{print $0}'); do
            lxcname=$container
            # echo $container
            case "$state" in
                start)
                    ./lxc_restart.sh $lxcname $defaultlxcname
                ;;

                stop)
                    ./lxc_stop_vpn_nsq.sh $lxcname
                ;;

                restart|reload|force-reload)
                    ./lxc_stop_vpn_nsq.sh $lxcname
                    ./lxc_restart.sh $lxcname
                ;;

                *)
                    echo "Usage: $0 $lxcname {start|stop|restart|reload|force-reload}"
                    exit 2
            esac
        done
    else
        # sed -n "2p" 查找第2行内
        # echo $(lxc list|awk -F '|' ' NR%3==1 && $2!="" && NR>2 {print $2}'|sed -n "${nr}p")
        lxcname=$(lxc list|awk ' NR>2 && $2!="" && $2!="|" {print $2}'|awk '{print $0}'|sed -n "${nr}p")
        echo $lxcname
        case "$state" in
            start)
                ./lxc_restart.sh $lxcname $defaultlxcname
            ;;

            stop)
                ./lxc_stop_vpn_nsq.sh $lxcname
            ;;

            restart|reload|force-reload)
                ./lxc_stop_vpn_nsq.sh $lxcname
                ./lxc_restart.sh $lxcname
            ;;

            *)
                echo "Usage: $0 {start|stop|restart|reload|force-reload} "
                exit 2
        esac
    fi
fi


exit $?