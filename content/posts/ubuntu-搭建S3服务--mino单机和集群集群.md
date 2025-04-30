---
title: "ubuntu 搭建S3服务  mino单机和集群集群"
categories: [ "linux" ]
tags: [ "minio","s3" ]
draft: false
slug: "ubuntu 搭建S3服务  mino单机和集群集群-ubuntu搭建s3服务mino单机和集群集群"
date: "2018-06-15 12:33:00"
---



# 搭建mino 集群

## 单机版

```shell
# 新建用户
sudo useradd -r minio-user -s /sbin/nologin
sudo chown -R minio-user:minio-user /usr/local/bin/minio
sudo mkdir /usr/local/share/minio
sudo chown -R minio-user:minio-user /usr/local/share/minio
sudo mkdir /etc/minio
sudo chown -R minio-user:minio-user /etc/minio
# 记得替换 MINIO_VOLUMES
cat  /etc/default/minio
# Local export path.
MINIO_VOLUMES=&quot;/tmp/minio/&quot;
# Use if you want to run Minio on a custom port.
MINIO_OPTS=&quot;--address :443&quot;
EOT
# 替换key
cat  /etc/default/minio
# Access Key of the server.
MINIO_ACCESS_KEY=Server-Access-Key
# Secret key of the server.
MINIO_SECRET_KEY=Server-Secret-Key
EOT
# 下载安装service文件
( cd /etc/systemd/system/; curl -O https://raw.githubusercontent.com/minio/minio-service/master/linux-systemd/minio.service )
# 记得替换 /etc/systemd/system/minio.service
# 中user和group
# 重载配置
systemctl daemon-reload
# 开机启动
systemctl enable minio.service
systemctl disable minio.service

```

## 集群版本

```shell
# 新建用户
useradd minio-user -s /sbin/nologin
# 记得替换 MINIO_VOLUMES
$ cat  /etc/default/minio
# Remote node configuration.
MINIO_VOLUMES=http://node1/export1 http://node2/export2 http://node3/export3 http://node4/export4
# Use if you want to run Minio on a custom port.
MINIO_OPTS=&quot;--address :9199&quot;
EOT
# 替换key
cat  /etc/default/minio
# Access Key of the server.
MINIO_ACCESS_KEY=Server-Access-Key
# Secret key of the server.
MINIO_SECRET_KEY=Server-Secret-Key
EOT
# 下载安装service文件
( cd /etc/systemd/system/; curl -O https://raw.githubusercontent.com/minio/minio-service/master/linux-systemd/distributed/minio.service )
# 记得替换 /etc/systemd/system/minio.service
# 中user和group
# 重载配置
systemctl daemon-reload
# 开机启动
systemctl enable minio.service
systemctl disable minio.service
systemctl restart minio.service
# 查看日志
journalctl -u nginx.service -f 
```

## 配置ssl证书

/home/minio/.minio/certs

```shell
# 安装acme.sh
 apt-get install libcurl4-openssl-dev
 curl https://get.acme.sh | sh
# 配置好dns
export CF_Email=&quot;xxxx&quot;
export CF_Key=&quot;xxx”
# 申请ssl
acme.sh --issue --dns dns_cf -d xx.com -d *.xx.com
acme.sh  --installcert  -d  xxx.com   \
        --key-file   /home/minio-user/.minio/certs/private.key \
        --fullchain-file /home/minio-user/.minio/certs/public.crt \
        --reloadcmd  &quot;systemctl restart minio.service&quot;
```

## 最后切换到ssl模式

```shell
vim /etc/default/minio
# 修改端口
MINIO_OPTS=&quot;--address :443&quot;
# 重启服务器
systemctl restart minio.service
```