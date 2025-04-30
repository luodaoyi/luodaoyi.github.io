---
title: 'Openwrt 路由器安装哪吒监控Agent'
date:  2024-10-02T15:34:48+08:00
categories: [ "linux" ]
tags: [ "dsm","群晖" ]
draft: false
---

最近想把路由器也接入nezha监控
于是乎研究下了下发现挺简单的

步骤如下


1. 下载agent 可执行文件
2. 编写init.d脚本设置开机启动


> 以下操作全部都在openwrt的ssh中执行

# 下载

``` shell
cd /tmp/upload/
wget https://github.com/nezhahq/agent/releases/download/v0.19.8/nezha-agent_linux_arm64.zip
unzip nezha-agent_linux_arm64.zip
mv nezha-agent /usr/sbin/nezha-agent
chmod +x /usr/sbin/nezha-agent

# 检查下是否成功
root@QWRT:/tmp/upload# nezha-agent -v
0.19.8

```

# 配置脚本并且设置开机启动

``` shell
vi /etc/init.d/nezha-service


输入以下内容:

#!/bin/sh /etc/rc.common

START=99
USE_PROCD=1

start_service() {
 procd_open_instance
 procd_set_param command /usr/sbin/nezha-agent -s 自己的服务器:443 -p 自己的密码 --tls --report-delay 4 --skip-conn --skip-procs  --ip-report-period 600  --disable-command-execute
 procd_set_param respawn
 procd_close_instance
}

stop_service() {
    killall nezha-agent
}

restart() {
 stop
 sleep 2
 start
}


#设置权限，否则会报错
chmod a+x  /etc/init.d/nezha-service

#设置开机启动
/etc/init.d/nezha-service enable

#启动服务
/etc/init.d/nezha-service start

#后续要关闭开启启动的话
/etc/init.d/nezha-service disable
```

ok了就这么简单