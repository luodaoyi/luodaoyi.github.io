---
title: "使用Metasploit收集邮箱信息"
categories: [ "安全" ]
tags: [ "系统安全" ]
draft: false
slug: "使用Metasploit收集邮箱信息-使用metasploit收集邮箱信息"
date: "2017-04-08 09:06:04"
---



Metasploit提供了很多辅助的模块，非常实用。今天介绍一个叫search\_email\_collector的模块，它的功能是查找搜索引擎（google、bing、yahoo），收集和某个域名有关的邮箱地址。

## 使用步骤：

启动msfconsole：

    # service postgresql start
    # msfconsole

搜索模块：

    msf > search gather auxiliary

找到search\_email\_collector：

![][1] 

使用search\_email\_collector：

    msf > use auxiliary/gather/search_email_collector

![][2] 

注：如果你不能使用google搜素，把SEARCH_GOOGLE设置为false：

     > set SEARCH_GOOGLE false

要收集某个域名的邮箱信息：

    > set DOMAIN your_target.com

开始收集：

    > run

由于使用搜索引擎，所以并不保证100%可靠。

黑客可以利用这些信息进行网络钓鱼，骗取个人信息。其实这种攻击是社会工程学攻击中最不危险的一种。

类似的工具还有theharvester：

    # theharvester
    # theharvester -d microsoft.com -l 500 -b google -h myresults.html
    # theharvester -d microsoft.com -b pgp
    # theharvester -d microsoft -l 200 -b linkedin
    # theharvester -d apple.com -b googleCSE -l 500 -s 300

 [1]: /uploads/oss/2017-04-25-14916424062946.png ""
 [2]: /uploads/oss/2017-04-25-14916424305678.png ""