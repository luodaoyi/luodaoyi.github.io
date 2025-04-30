---
title: "Realm端口转发工具简单使用"
categories: [ "linux" ]
tags: [  ]
draft: false
slug: "205"
date: "2023-11-07 16:19:00"
---

Realm 是Rust语言开发的流量转发工具，Realm 比 Gost占用资源更小。

支持多组服务器转发，同时也支持tcp和udp，还有域名解析便捷。

据我的测试结果来看，对于RDP的转发 realm 比市面上别的转发工具延迟都要明显低一些。

1. 下载最新的可执行文件到本地：

Github 以最新版本为主，根据自己的系统版本下载即可，

比如我的是64位Debian系统，则需下载 [realm-x86_64-unknown-linux-gnu.tar.gz][1]
也可以下载 musl 版本的 musl是静态编译版本 体积稍大 

```sh
cd /usr/local/bin
wget https://github.com/zhboner/realm/releases/download/v2.4.6/realm-x86_64-unknown-linux-gnu.tar.gz
tar -zxvf realm-x86_64-unknown-linux-gnu.tar.gz
```

2. 赋予程序可执行权限：

```sh
chmod +x realm

```

3. 创建realm配置文件：

realm 最新版的配置文件为 toml 结尾的文本文件

```sh
mkdir -p /etc/realm
vim /etc/realm/config.tml
```

具体的配置文件规则很简单，只需要在 listen 里填入vps上的带转发端口号，remote 中填入目的地的vps的ip和端口号即可：


```toml
[network]
no_tcp = false
use_udp = true

[[endpoints]]
listen = "0.0.0.0:23456"
remote = "test.cloudflare.com:23456"

[[endpoints]]
listen = "0.0.0.0:54321"
remote = "1.1.1.1:443"
```


配置文件支持各种协议，以及域名解析等操作，更多规则可以查看项目 [Github主页][2]

4. 创建自启动服务项：

使用systemd 来创建开机启动防止机器重启了服务没了

```sh
vim /etc/systemd/system/realm.service

[Unit]
Description=realm
After=network-online.target
Wants=network-online.target systemd-networkd-wait-online.service

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
DynamicUser=true
ExecStart=/usr/local/bin/realm -c /etc/realm/config.tml

[Install]
WantedBy=multi-user.target
```

5. 开启服务配置自启

```sh
systemctl daemon-reload
systemctl enable realm && systemctl start realm

# ps: 禁用自启

systemctl stop realm && systemctl disable realm

```

如果你的落地服务器使用的是动态IP，或者DDNS服务，可以在 crontab 计划任务里来设置定时重启realm服务：

```sh
cronteb -e

#填写内容为时间和重启的服务名称：

00 5 * * * systemctl restart realm
```

6. 测试是否成功转发：

此时就应该可以成功通过这台 vps 来转发落地服务器的任何流量了，
如果发现无法转发，可以看一下是否开启了selinux、iptables、防火墙规则等等干扰了程序端口运行。
关闭干扰的防火墙规则或者添加转发端口到白名单即可，
如果还是无法转发可以查看一下realm日志log判断错误所在：

```sh
tail /var/log/realm.log -f
# 如果没有配置log字段那么就 使用journalctl  查看日志

journalctl -u realm -f
```

一般的错误都是域名解析失败，可以改变系统的DNS为 8.8.8.8 即可。

参考：
[Realm端口转发工具安装教程][3]


  [1]: https://github.com/zhboner/realm/releases/download/v2.4.6/realm-x86_64-unknown-linux-gnu.tar.gz
  [2]: https://github.com/zhboner/realm
  [3]: https://zhucaidan.xyz/2022/09/570/