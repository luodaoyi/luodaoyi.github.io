---
title: "阿里云，腾讯云，等等的云 Ubuntu14.04升级16.04"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "阿里云，腾讯云，等等的云 Ubuntu1404升级1604-阿里云腾讯云等等的云ubuntu1404升级1604"
date: "2017-03-12 06:30:15"
---



> 16.04有很多好处。在此不说了  
> 这几天来回折腾了各种的云，然后发现国内的都没有16.04 但是ubuntu可以直接在线升级

在此记下来升级的过程

不管是腾讯云也好 阿里云也好，或者别的什么云，只要是国内的 几乎都不提供ubuntu16.04的镜像，但是我们可以在线升级  
下面是过程记录

### 1. 买vps装ubuntu14.04

怎么买？ 这个就不说 要是都不会买 还是去玩LOL吧

下面是重点  
如果你是阿里云 那么直接跳到3，如果是别的什么云 比如腾讯云那就需要改`apt-get`源了

### 2. 改`apt-get`源

执行命令打开`sources.list`

    sudo vim /etc/apt/sources.list
    

然后吧内容清空

输入阿里云的外网源，原因就是速度快 而且有16.04的镜像，腾讯云是没有的我发了工单也没人理

    # deb http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse # disabled on upgrade to xenial
    # deb http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse # disabled on upgrade to xenial
    # deb http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse #Not for humans during development stage of release xenial
    # deb http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse # disabled on upgrade to xenial
    # deb-src http://mirrors.aliyun.com/ubuntu/ xenial main restricted universe multiverse # disabled on upgrade to xenial
    # deb-src http://mirrors.aliyun.com/ubuntu/ trusty-security main restricted universe multiverse # disabled on upgrade to xenial
    # deb-src http://mirrors.aliyun.com/ubuntu/ trusty-updates main restricted universe multiverse # disabled on upgrade to xenial
    # deb-src http://mirrors.aliyun.com/ubuntu/ xenial-proposed main restricted universe multiverse #Not for humans during development stage of release xenial
    # deb-src http://mirrors.aliyun.com/ubuntu/ trusty-backports main restricted universe multiverse # disabled on upgrade to xenial
    

保存退出

### 3. 更新和升级

现在要吧14.04的所有软件升级到最新，并且执行升级，不升级软件也行出问题就自己解决。。

    sudo apt-get update && sudo apt-get dist-upgrade

完事重启系统以完成更新的安装

    sudo init 6

重启成功后  
用命令安装更新管理器核心`update-manager-core`，如果服务器已安装则可以跳过

    sudo apt-get install update-manager-core

编辑`/etc/update-manager/release-upgrades`配置文件，设置`Prompt=lts`

    sudo vim /etc/update-manager/release-upgrades

设置好时候 保存退出

## 4. 重头戏！启动升级进程

现在要启动升级了

     sudo do-release-upgrade -d`

一路有提示就按y 该同意就同意，最好看一下提示的内容根据要求来操作

### 重启,进入新系统

以上都完成后 会提示需要重启,那我们就重启

    sudo init 6

升级完成！

现在Server已经升级到Ubuntu Server 16.04（Xenial Xerus）LTS。