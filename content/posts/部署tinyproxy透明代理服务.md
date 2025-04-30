---
title: "部署tinyproxy透明代理服务"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "部署tinyproxy透明代理服务-部署tinyproxy透明代理服务"
date: "2017-03-12 06:27:46"
---



线上需要一个https的透明代理，开始打算用nginx，调试了一段时间发现配置较复杂且没有成功。后来用的tinyproxy做的透明代理。安装配置过程就是下载、解压、编译、安装、配置、启动一波流：

# 安装依赖

`sudo apt-get install asciidoc`

# 下载

`sudo wget https://github.com/tinyproxy/tinyproxy/releases/download/1.8.4/tinyproxy-1.8.4.tar.gz -O tinyproxy-1.8.4.tar.gz`

# 解压

`sudo tar xvfz tinyproxy.1.8.4.tar.gz`

# 编译配置

`./configure --enable-transparent --prifix=/usr/local/tinyproxy`  
更多的编译选项可以参考源码目录的README文件，部分说明如下：

    ----
    ./configure
    make
    make install
    ----
    in the top level directory to compile and install Tinyproxy. There are
    additional command line arguments you can supply to `configure`. They
    include:
        --enable-debug        If you would like to turn on full
                    debugging support
        --enable-xtinyproxy    Compile in support for the XTinyproxy
                    header, which is sent to any web
                    server in your domain.
        --enable-filter        Allows Tinyproxy to filter out certain
                    domains and URLs.
        --enable-upstream    Enable support for proxying connections
                    through another proxy server.
        --enable-transparent
                    Allow Tinyproxy to be used as a
                    transparent proxy daemon
        --enable-static        Compile a static version of Tinyproxy
            --with-stathost=HOST    Set the default name of the stats host
    Support
    -------

# 编译

`sudo make`

# 安装

`sudo make install`

    
    修改配置文件一般需要指定用户、用户组、端口、访问IP段，当然这些都有默认值，然后启动程序和测试。

# 启动程序：

`/usr/local/tinyproxy/sbin/tinyproxy -c /usr/local/tinyproxy/etc/tinyproxy.conf`

# 测试代理节点是否生效(假设代理程序安装在10.10.10.10的机器，监听的是8888端口)：

`curl url --proxy 10.10.10.10:8888`

# 如果是https代理加 -k 参数

`curl url --proxy 10.10.10.10:8888 -k`

    
    关于配置文件的一点补充：

# 添加多段IP地址

    Allow 10.27.80.0/24
    Allow 11.65.48.0/24
    Allow 18.90.12.145

# 添加head信息,https的代理不能添加(一条信息一条记录和ip访问限制设置一样)

    AddHeader "Referer" "http://www.baidu.com"