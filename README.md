# openvpn_lxc
openvpn 安装 

## 1. 主要功能

### 1.1 功能描述

- [x] 根据 [<font color=#0099ff>openvpn shell</font>](https://github.com/Nyr/openvpn-install) 改了点，加了个移除现有的openvpn用户
- [x] 重点是：阿里云服务器崩溃，重启服务器之后lxc 容器内部不联网了，以及openvpn，nsq全部被移除，修复此类问题


## 2. 使用场景

- ***使用场景***

    1、./ecs_restart_lxc_config.sh start|stop|restart|reload|force-reload
    2、必须下载chrome浏览器
