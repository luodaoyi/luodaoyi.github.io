---
title: "lnmp自动备份网站文件和数据库并上传到谷歌云盘"
categories: [ "linux" ]
tags: [ "lnmp" ]
draft: false
slug: "lnmp自动备份网站文件和数据库并上传到谷歌云盘-lnmp-zi-dong-bei-fen-wang-zhan-wen-jian-he-shu-ju-ku-bing-shang-chuan-dao-gu-ge-yun-pan"
date: "2022-10-10 08:06:53"
---


## 修改备份脚本参数

修改/root/lnmp1.8/tools/backup.sh 备份脚本的几个参数。清注意：如果升级了lnmp一键安装包，此文件应需要再次修改。

```bash
Backup_Home="/home/backup/"  # 此为备份文件存放目录
MySQL_Dump="/usr/local/mysql/bin/mysqldump"  # mysqldump路径,如果是mariadb,替换/usr/local/mysql为/usr/local/mariadb
######~Set Directory you want to backup~######
Backup_Dir=("/home/wwwroot/aaa.com" "/home/wwwroot/avatar.aaa.com")  # 要备份的目录，目录用双引号括起来，多个目录空格隔开

######~Set MySQL Database you want to backup~######
Backup_Database=("lnmp" "aaa")  # 要备份的数据库，目录用双引号括起来，多个目录空格隔开

######~Set MySQL UserName and password~######
MYSQL_UserName='root'  # MySQL root账号
MYSQL_PassWord='yourrootpassword'  # MySQL root密码

######~Enable Ftp Backup~######
Enable_FTP=0  # 是否启用ftp备份。0 启用；1 不启用
# 0: enable; 1: disable
######~Set FTP Information~###### ftp账号信息
FTP_Host='1.2.3.4'
FTP_Username='aaa.com'
FTP_Password='yourftppassword'
FTP_Dir="backup"  # ftp服务器上存放备份的目录

#Values Setting END! 默认备份文件保存3天，可以修改backup.sh里的-3day为你指定的天数。
```

## Gdrive 安装与谷歌云盘授权

Gdrive项目地址：[https://github.com/prasmussen/gdrive](https://github.com/prasmussen/gdrive)，gdrive 是用于与 Google Drive 交互的命令行实用程序。

选择适合自己服务器的Gdrive版本下载安装。安装2.1.1版本gdrive时，在执行 `gdrive about `命令后，若出现 `-bash: /usr/local/bin/gdrive: No such file or directory` 错误，那么执行`apt install -y musl`可解决。


```bash
cd /usr/bin
wget https://github.com/prasmussen/gdrive/releases/download/2.1.1/gdrive_2.1.1_linux_amd64.tar.gz
tar -zxf gdrive_2.1.1_linux_amd64.tar.gz
chmod +x /usr/bin/gdrive
apt install -y musl
gdrive about
```

执行后以上命令后，会出现一串URL并询问验证码，将URL地址复制粘贴到浏览器打开。
![image](/files/image.png)

允许你要授权的谷歌账号，将返回的验证码复制粘贴到连接VPS的终端中。

![image-1665388949237](/files/image-1665388949237.png)

![image-1665388954888](/files/image-1665388954888.png)


返回谷歌账号信息表示gdrive已安装并配置完成。


![image-1665388965679](/files/image-1665388965679.png)


设置自动上传Google Drive脚本


编写脚本并添加到cron（基于时间的任务管理系统）使其按规定时间将备份文件夹上传到谷歌云盘，直接在vps上编辑 `backup.sh`


在最后加上上传的命令即可

```bash
/usr/bin/gdrive upload --recursive  /home/backup

```

试运行一次网站备份自动上传脚本。


```bash
/bin/bash /root/lnmp1.9/tools/backup.sh
```
![image-1665389125492](/files/image-1665389125492.png)
出现Uploading …，表示脚本执行成功。接下来执行

```bash
crontab -e
```

在最后一行添加

```bash

0 3 */3 * * /bin/bash /root/lnmp1.9/tools/backup.sh
```


其中`/root/lnmp1.9/tools/backup.sh`是脚本的完整路径，你可以根据自己的喜好修改。保存成功后，服务器每隔3天的凌晨3点0分，系统会自动备份服务器网站文件和数据库并上传到Google Drive。

