---
title: "通过SNI Proxy加速国内服务器的WordPress更新"
categories: [ "linux","工具" ]
tags: [ "linux","工具","wordpress" ]
draft: false
slug: "通过SNI Proxy加速国内服务器的WordPress更新-通过sniproxy加速国内服务器的wordpress更新"
date: "2020-04-02 08:05:47"
---



相信很多在国内服务器搭建WordPress的同学都有过这样的烦恼：更新不成功，后台某些页面打卡非常慢，插件主题没法在线安装等等等等这些问题，而且如果你的服务器又因为某些因素不方便直接搭建$$r之类的软件来给它加速，每次手动下载安装包再上传安装会是一件非常头疼的事。

注意，此方法并不能让你国内的服务器访问被屏蔽的网站，只能加速没有被屏蔽的网站

## 首先，你需要准备：

  * 一个国内的服务器，已经装好WordPress（当然了）
  * 一个国外的服务器

> 注：本教程的环境为Centos7

## 1. 安装所需的软件包


```shell

# Centos8用dnf会更快一些：
sudo dnf install autoconf automake curl gettext-devel libev-devel pcre-devel perl pkgconfig rpm-build udns-devel git
# Centos7及以下：
sudo yum install autoconf automake curl gettext-devel libev-devel pcre-devel perl pkgconfig rpm-build udns-devel git 

```


## 2. 下载源码并编译安装

  1. 克隆源码
    
    
```shell
cd ~/
git clone https://github.com/dlundquist/sniproxy.git
cd sniproxy/
```


  2. 构建包：
    
    
```shell
./autogen.sh && ./configure && make dist
```


在这一步有可能会看到./setver.sh: line 35: debchange: command not found报错，在Centos上这个是正常现象，不用理会即可

   3. 构建RPM包：

   **注：这一步是最重要的，网络上其他教程大部分都不能在Centos上正常编译**

安装官方教程执行`rpmbuild --define "_sourcedirpwd" -ba redhat/sniproxy.spec`会发现报错


```shell
RPM build errors:
    Bad exit status from /var/tmp/rpm-tmp.Yh1p0x (%build)
```


这时需要编辑`redhat/sniproxy.spec`，在26行找到`%configure CFLAGS="-I/usr/include/libev"`，把这一行改为`%configure CFLAGS="-fPIC -I/usr/include/libev"`

[![][1]][2]

然后再执行


```shell
rpmbuild --nodebuginfo --define "_sourcedir `pwd`" -ba redhat/sniproxy.spec

# 更新
rpmbuild --define "_sourcedir `pwd`" -ba redhat/sniproxy.spec

```


即可正常编译

  4. 安装RPM包 :

```shell
cd ~/rpmbuild/RPMS/x86_64/
sudo yum localinstall sniproxy-<version>.<arch>.rpm
```
 

## 3. 配置并运行sniproxy

  1. 编辑配置文件 `/etc/sniproxy.conf`


```nginx
user daemon
pidfile /var/run/sniproxy.pid
resolver {
nameserver 1.1.1.1
nameserver 1.0.0.1
mode ipv4_only
}
error_log {
    filename /var/log/sniproxy_error.log
    priority debug
}
# listen 0.0.0.0 80 {
#   table https_hosts
# }
listen 0.0.0.0 443 {
   proto tls
   table https_hosts
   access_log {
       filename /var/log/sniproxy_access.log
       priority notice
   }
}
table https_hosts {
    (.*.|)wordpress.org$ *
}
```

  2. 编辑systemd自动启动脚本


```nginx
vim /etc/systemd/system/sniproxy.service
# 下面是配置

[Unit]
Description=sniproxy servier
After=network.target

[Service]
ExecStart=/usr/sbin/sniproxy -c /etc/sniproxy.conf -f
Restart=always

[Install]
WantedBy=multi-user.target

# 下面是相关命令
# 配置重载(修改了systemd配置之后都要执行这条命令)
systemctl daemon-reload

# 配置开机启动
systemctl enable sniproxy

# 启动
systemctl start sniproxy
# 重启
systemctl restart sniproxy
# 停止
systemctl stop sniproxy
# 查看状态
systemctl status sniproxy
```


然后再执行sniproxy即可正常运行

## 4. 国内服务器配置

回到国内运行WordPress的服务器上，编辑/etc/hosts，添加以下行


```conf
1.1.1.1 wordpress.org
1.1.1.1 api.wordpress.org
1.1.1.1 cn.wordpress.org
1.1.1.1 downloads.wordpress.org
#注意把1.1.1.1换成正在运行sniproxy的服务器的ip
```


我搞了一个不保证随时可以用 不能的话 给我留个言我来看看


```conf
144.34.204.235 wordpress.org
144.34.204.235 api.wordpress.org
144.34.204.235 cn.wordpress.org
144.34.204.235 downloads.wordpress.org
```


再回到WordPress后台，会发现可以更新和安装插件了。

 [1]: /uploads/2020/04/修改-300x71.png
 [2]: https://luodaoyi.com/?attachment_id=2113