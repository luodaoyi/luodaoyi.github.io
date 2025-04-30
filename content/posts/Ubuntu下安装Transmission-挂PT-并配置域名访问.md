---
title: "Ubuntu下安装Transmission 挂PT 并配置域名访问"
categories: [ "linux","工具" ]
tags: [ "linux" ]
draft: false
slug: "Ubuntu下安装Transmission 挂PT 并配置域名访问-ubuntu下安装transmission挂pt并配置域名访问"
date: "2017-12-02 04:48:00"
---



![][1]

## 安装 Transmission

    sudo apt-get install transmission-daemon

## 修改配置文件

先停止transmission

    sudo service transmission-daemon stop
    

编辑

    sudo vim /etc/transmission-daemon/settings.json
    第14行修改为“dht-enabled”: false,
    第15行是下载目录修改成你自己的“download-dir”: “/home/transmission/downloads”,
    第20行修改为“encryption”: 2,
    第23行修改为  "incomplete-dir": "/home/transmission/tmp",
    第49行修改自定义的密码“rpc-password”: “123456”,
    第52行修改成自定义的登录账号名称“rpc-username”: “transmission”,
    第54行修改为“rpc-whitelist-enabled”: false,

## 建立文件夹和修改权限

    sudo mkdir -p /home/transmission/downloads
    sudo mkdir -p /home/transmission/tmp
    sudo usermod -a -G transmission root
    sudo chgrp -R transmission /home/transmission
    

检查目录用户组

    cd /home/transmission
    ls -lh

出现如下所示就OK

    drwxr-xr-x 3 root transmission 4.0K Jun 10 01:51 debian-transmission
    drwxrwxrwx 2 root transmission 4.0K Jun 10 01:49 downloads

## 美化

项目地址 : <https://github.com/ronggang/transmission-web-control>

    cd /usr/share/transmission/web
    sudo mv index.html index.original.html
    sudo wget https://github.com/ronggang/transmission-web-control/raw/master/release/src.tar.gz
    sudo tar -xzvf src.tar.gz
    sudo mv src.tar.gz

## 启动transmission

    sudo service transmission-daemon start

## 配置反向代理

这里使用caddy 方便快捷  
安装caddy

    cd
    sudo wget -N --no-check-certificate https://raw.githubusercontent.com/luodaoyi/SimplesScript/master/caddy_install.sh
    sudo chmod +x caddy_install.sh
    sudo ./caddy_install.sh install http.filemanager

这里要提前解析好自己的域名到服务器的ip 否则无法申请自动成功ssl证书

    echo "https://yourdomain {
     gzip
     tls youemail
     proxy / http://127.0.0.1:9091
    }" > /usr/local/caddy/Caddyfile

重启caddy

    sudo service caddy restart

好了至此安装完毕。打开你的域名看看吧！

 [1]: https://ws3.sinaimg.cn/large/006tNc79ly1fm2au5zmrqj319d0mzjsv.jpg ""