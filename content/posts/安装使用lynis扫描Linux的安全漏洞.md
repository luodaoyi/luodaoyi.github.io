---
title: "安装使用lynis扫描Linux的安全漏洞"
categories: [ "安全" ]
tags: [ "系统安全" ]
draft: false
slug: "安装使用lynis扫描Linux的安全漏洞-安装使用lynis扫描linux的安全漏洞"
date: "2017-04-08 08:56:01"
---



`Lynis`是Linux平台上的一款安全漏洞扫描工具。它可以扫描系统的安全漏洞、收集系统信息、安装的软件信息、配置问题、没有设置密码的用户和防火墙等等。

Lynis是流行可靠的安全扫描工具。

前不久，Lynis更新了版本，Lynis发布了2.2.0。在这个版本上增加了新的特性和一些小的功能提升。我建议使用Lynis的最新版本2.2.0。

下面我在Ubuntu上安装Lynis 2.2.0。

## 安装Lynis

Lynis可以安装在系统中的任意目录，创建一个目录/opt/lynis：

    $ sudo mkdir /opt/lynis

使用wget下载Lynis：

    cd /opt/lynis
    $ sudo wget https://cisofy.com/files/lynis-2.2.0.tar.gz

解压下载的tar包：

    $ sudo tar -xvf lynis-2.2.0.tar.gz

## 使用Lynis

运行lynis需要root权限，执行：

    cd lynis
    $ sudo ./lynis

不给指定参数，它会列出可用的参数，如下图：

![][1] 

为了执行Lynis，你可以指定&#8211;check-all开始扫描整个Linux系统。命令如下：

    $ sudo ./lynis --check-all

键入回车开始扫描系统：

![][2] 

![][3] 

执行上面命令总需要输入回车才能往下执行，你可以使用-c和-Q选项跳过用户输入：

    $ sudo ./lynis -c -Q

## 创建Lynis计划任务－cron job

如果你想为你的系统创建一个日扫描报告，你可以设置cron：

    $ crontab -e

添加cron任务：

    30    22    *    *    *    root    /opt/lynis -c -Q --auditor "automated" --cronjob

上面任务每天晚上10:30会执行扫描，并把输出的信息保存到/var/log/lynis.log日志文件中。

 [1]: /uploads/oss/2017-04-25-14916422703353.png ""
 [2]: /uploads/oss/2017-04-25-14916422915898.png ""
 [3]: /uploads/oss/2017-04-25-14916422967967.png ""