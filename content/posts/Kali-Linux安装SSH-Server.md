---
title: "Kali Linux安装SSH Server"
categories: [ "安全" ]
tags: [ "系统安全" ]
draft: false
slug: "Kali Linux安装SSH Server-kalilinux安装sshserver"
date: "2017-04-08 09:17:21"
---



Kali Linux默认并没有安装SSH服务，为了实现远程登录Kali Linux，我们需要安装SSH服务。

## 安装 OpenSSH Server

    # apt-get install openssh-server

## 配置SSH服务开机启动

    # update-rc.d -f ssh remove
    # update-rc.d -f ssh defaults
    # update-rc.d -f ssh enable 2 3 4 5

## 更改默认的SSH密钥

    # cd /etc/ssh
    # mkdir ssh_key_backup
    # mv ssh_host_* ssh_key_backup

## 创建新密钥：

    # dpkg-reconfigure openssh-server

## 允许root用户使用ssh远程登录

默认下，不允许使用root用户进行ssh远程登录，需要改一下ssh的配置文件：

    # vim /etc/ssh/sshd_config

把：

    PermitRootLogin prohibit-password

改为：

    PermitRootLogin yes

重启SSH：

    # service ssh restart

## 使用其他计算机远程登录

![][1] 

OK，SSH服务设置完成。

从上图可以看到，登录成功之后，会有一些问候信息 balabala。这些文字信息是可以自定义的：

    # vim /etc/motd

写入你想要的问候文字。

重启SSH：

    # service ssh restart

![][2]

 [1]: /uploads/oss/2017-04-25-14916431419269.png ""
 [2]: /uploads/oss/2017-04-25-14916431792445.png ""