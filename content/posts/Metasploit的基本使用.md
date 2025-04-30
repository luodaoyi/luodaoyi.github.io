---
title: "Metasploit的基本使用"
categories: [ "安全" ]
tags: [ "系统安全" ]
draft: false
slug: "Metasploit的基本使用-metasploit的基本使用"
date: "2017-04-08 08:51:46"
---



Metasploit可以在Linux、Windows和Mac OS X系统上运行。我假设你已安装了Metasploit，或者你使用的系统是Kali Linux。它有命令行接口也有GUI接口。

我使用的系统是Kali Linux，本文以这个系统为例。

图形用户界面接口：Armitage

![][1] 

命令行接口：msfconsole

    msfconsole

![][2] 

使用metasploit的基本步骤：

  * 运行msfconsole
  * 确定远程主机
  * 找到一个漏洞并使用这个漏洞
  * 配置漏洞选项
  * 入侵远程主机

metasploit内建了很多文档，查看方法：

    msf > help
    msf > help search

## 获得远程主机信息

你可以在mfs中运行nmap命令：

    msf > nmap -v -sV some_host

也可以使用db_nmap，结果输出到metasploit数据库：

    msf > db_nmap -v -sV some_host

更多扫描工具：

    msf > search portscan

列出db_nmap找到的主机：

    msf > hosts

把这些主机加入到目标主机：

    msf > hosts -R

也可以使用set RHOST your\_target\_ip设置目标IP。

这一步的目的是获得要目标主机的系统信息，为下一步选择漏洞和利用漏洞做准备。

其他扫描漏洞的工具：lynix、maltego、wp-scan等等。

* * *

显示metasploit中所有可以利用的模块：

    msf > show
    msf > show auxiliary
    msf > show exploits
    msf > show payloads
    msf > show encoders
    msf > show nops

搜索可以利用的漏洞：

    msf > search type:exploit
    msf > search CVE-xxxx-xxx
    msf > search cve:2014
    msf > search name:wordpress
    msf > search name:mysql
    msf > search path:scada
    msf > search platform:aix
    msf > search type:post
    msf > search windows type:exploit
    ...

使用一个漏洞：

    msf > use exploit/path/to/exploit_name

设置payload：

    msf > show payloads
    msf > set payload path/to/payload

入侵：

    msf > exploit

如果没有成功，重新选择漏洞。

 [1]: /uploads/oss/2017-04-25-14916415182006.png ""
 [2]: /uploads/oss/2017-04-25-14916415391013.png ""