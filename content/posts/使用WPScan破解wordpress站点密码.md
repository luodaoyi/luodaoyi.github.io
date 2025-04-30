---
title: "使用WPScan破解wordpress站点密码"
categories: [ "安全" ]
tags: [ "web安全" ]
draft: false
slug: "使用WPScan破解wordpress站点密码-使用wpscan破解wordpress站点密码"
date: "2017-04-08 08:20:14"
---



我这里使用的Kali Linux，它默认安装了WPScan。

![][1] 

在使用WPScan之前，先更新它的漏洞数据库：

    # wpscan –update

扫描wordpress用户

    wpscan -–url [wordpress网址] –-enumerate u

以我的网站为例：

    # wpscan --url http://blog.topspeedsnail.com --enumerate u

> 注意：要用使用两个–，否则报错－“The WordPress URL supplied ‘<http://rl/>’ seems to be down.”

![][2] 

暴力破解：

    wpscan --url [wordpress网址] --wordlist [字典文件] --username [要破解的用户] --threads [开启的线程数]

我已test用户为例：

    # wpscan --url http://blog.topspeedsnail.com --wordlist ~/password.txt --username test --threads 

![][3] 

好的密码字典应包含常见的弱密码、手机号、姓名生日组合、各大网站泄露的密码、英语单词等等。如果使用字典破解不了，说明密码还算复杂；暴力穷举更是费时费力。

怎么防止wordpress网站被人使用上面方法破解呢？

防止暴力破解的最好方式是限制一个IP地址的尝试登录次数。WordPress有n多插件可以实现这个功能。我使用的一个插件叫：Brute Force Login Protection。

 [1]: /uploads/oss/2017-04-25-14916396779113.png ""
 [2]: /uploads/oss/2017-04-25-14916397851782.png ""
 [3]: /uploads/oss/2017-04-25-14916398753589.png ""