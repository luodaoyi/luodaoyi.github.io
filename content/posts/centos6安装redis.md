---
title: "centos6安装redis"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "centos6安装redis-centos6安装redis"
date: "2017-03-12 06:31:19"
---



  1. 检查安装依赖程序

    yum install gcc-c++
    yum install -y tcl
    yum install wget

  1. 获取安装文件

    wget http://download.redis.io/releases/redis-2.8.13.tar.gz

  1. 解压文件

    tar -xzvf redis-2.8.19.tar.gz
    mv redis-2.8.19 /usr/local/redis

  1. 进入目录

    cd /usr/local/redis

  1. 编译安装

    make
    make install

  1. 设置配置文件路径

    mkdir -p /etc/redis
    cp redis.conf/etc/redis

  1. 修改配置文件

    vi /etc/redis/redis.conf
    仅修改： daemonize yes （no-->yes）

  1. 启动

    /usr/local/bin/redis-server /etc/redis/redis.conf

  1. 查看启动

    ps -ef | grep redis 

  1. 使用客户端

    redis-cli
    >set name david
    OK
    >get name
    "david"

  1. 关闭客户端

    redis-cli shutdown

  1. 开机启动配置

    echo "/usr/local/bin/redis-server /etc/redis/redis.conf &" >> /etc/rc.local

开机启动要配置在 rc.local 中，而 /etc/profile 文件，要有用户登录了，才会被执行。