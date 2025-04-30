---
title: "在ubuntu16.04上安装php7 mysql5.7 nginx1.10并支持http2"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "在ubuntu1604上安装php7 mysql57 nginx110并支持http2-在ubuntu1604上安装php7mysql57nginx110并支持http2"
date: "2017-03-12 06:30:31"
---



# 安装nginx

首先更新软件包 并且安装nginx

    sudo apt-get update
    sudo apt-get install nginx

开放防火墙配置

    sudo ufw allow "Nginx HTTP"
    

查看防火墙状态

    sudo ufw status
    ------------------
    Status: active
    To                         Action      From
    --                         ------      ----
    OpenSSH                    ALLOW       Anywhere
    Nginx HTTP                 ALLOW       Anywhere
    OpenSSH (v6)               ALLOW       Anywhere (v6)
    Nginx HTTP (v6)            ALLOW       Anywhere (v6)

访问服务器看看nginx是否配置成功

    http://server_domain_or_IP

# 2安装mysql

    sudo apt-get install mysql-server

安装期间会配置数据库的root密码 而且默认的root账户不可以远程登录  
如果密码忘了可以执行如下命令来重设密码

    sudo mysql_secure_installation

如果需要远程登录mysql的root账户

可以执行

    mysql -uroot -p
    输入root密码  进入mysql命令行
    执行mysql命令
    mysql>use mysql;
    mysql>update user set host = "%" where user = "root";
    mysql>select host, user from user;

然后重启msql 就可以远程root登录了

    service mysql restart

# 3安装php

    sudo apt-get install php-fpm php-mysql

配置php

    sudo vim /etc/php/7.0/fpm/php.ini

修改`cgi.fix_pathinfo`为0,防止安全泄露

    cgi.fix_pathinfo=0

保存关闭 ，重启php

    sudo systemctl restart php7.0-fpm

# 配置nginx 使用php

找到站点配置

    sudo vim /etc/nginx/sites-available/default

大概修改成下面这样，根据情况自行配置

    server {
        listen 80 default_server;
        listen [::]:80 default_server;
        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name server_domain_or_IP;
        location / {
            try_files $uri $uri/ =404;
        }
        location ~ \.php$ {
            include snippets/fastcgi-php.conf;
            fastcgi_pass unix:/run/php/php7.0-fpm.sock;
        }
        location ~ /\.ht {
            deny all;
        }
    }

只需要保证 `index`配置有`index.php` 在`location`中有`fastcgi_pass` 并且配置正确就可以

检查nginx配置

    sudo nginx -t

重启nginx

    sudo systemctl reload nginx
    当然 service也可以
    service nginx restart

# 5添加php文件测试配置

    sudo vim /var/www/html/info.php

添加下面代码