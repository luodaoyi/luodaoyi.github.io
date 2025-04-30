---
title: "Online.net 的ubuntu增加ipv6地址"
categories: [ "linux" ]
tags: [ "linux","ubuntu","debian" ]
draft: false
slug: "Onlinenet 的ubuntu增加ipv6地址-onlinenet的ubuntu增加ipv6地址"
date: "2018-01-10 01:49:00"
---



官方教程有问题

这里总结下，省的下次又不会配了

## 配置 ipv6 block

![][1] 

打开 <https://console.online.net/en/network/> 创建子网

![][2] 

## 配置 仓储地址

编辑 `sources.list`

    sudo vim /etc/apt/sources.list 

在末尾增加dhcp6的源地址

    #DHCP6 Client
    deb http://httpredir.debian.org/debian experimental main  

然后创建 apt 偏好文件

    sudo vim /etc/apt/apt.conf.d/99defaultrelease  

这里 14.04填写

    APT::Default-Release "jessie";  

16.04填写

    APT::Default-Release "xenial";  

更新apt源

    sudo apt update
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8B48AD6246925553
    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7638D0442B90D010

## 安装设置DHCP6 客户端

    sudo apt-get install odhcp6c  

然后测试命令

    odhcp6c -P 掩码(一般是56) -c DUID(网络配置中有) eth0(网卡名称 可以用ifconfig查看) -d  

然后注册 ipv6

    ip -6 a a 2001:bc8:3d8b:100::0/56(这里就是配置的子网) dev eth0(网卡地址)  

然后ping测试

    ping6 online.net

然后你必须看到想这样的,说明已经有ipv6了

    PING online.net(www.online.net) 56 data bytes
    64 bytes from www.online.net: icmp_seq=1 ttl=61 time=0.286 ms
    64 bytes from www.online.net: icmp_seq=2 ttl=61 time=0.318 ms
    64 bytes from www.online.net: icmp_seq=3 ttl=61 time=0.372 ms
    64 bytes from www.online.net: icmp_seq=4 ttl=61 time=0.285 ms
    64 bytes from www.online.net: icmp_seq=5 ttl=61 time=0.326 ms
    ^C
    --- online.net ping statistics ---
    5 packets transmitted, 5 received, 0% packet loss, time 4004ms
    rtt min/avg/max/mdev = 0.285/0.317/0.372/0.035 ms 

## 设置开机自动注册ipv6

编辑显卡配置文件

    sudo vim /etc/network/interfaces

添加配置

    #DHCP6 client
    post-up odhcp6c -P 56 -c 00:03:00:00:00:00:00:00:00:00 eth0 -d
    post-up ip -6 a a 2001:bc8:3d8b:100::0/56 dev eth0  

下面是我的配置 仅供参考

    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).
    source /etc/network/interfaces.d/*
    # The loopback network interface
    auto lo
    iface lo inet loopback
    # The primary network interface
    auto enp0s20f0
    iface enp0s20f0 inet dhcp
    #DHCP6 client
    post-up odhcp6c -P 56 -c 00:03:00:01:fc:7d:xx:xx:xx:xx enp0s20f0 -d
    post-up ip -6 a a 2001:bc8:3c10:100::0/56 dev enp0s20f0

如果你想绑定多个ip的话 那就多往下写一个 `ip` 这样类似的配置就可以了

 [1]: /uploads/oss/2018-01-10-15155490668090.png ""
 [2]: /uploads/oss/2018-01-10-15155491317895.png ""