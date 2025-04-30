---
title: "Nginx 反向代理nuget配置文件"
categories: [ "linux" ]
tags: [ "linux","nginx","nuget","ssl" ]
draft: false
slug: "Nginx 反向代理nuget配置文件-nginx反向代理nuget配置文件"
date: "2017-11-28 15:14:00"
---



![2][1]

前提条件 域名要解析到服务器ip上去

## ubuntu16.04 安装Nginx

非常简单，因为需要喜欢内容所以装的是full版本

    sudo apt update -y sudo apt install nginx-full -y

安装好之后配置好反向代理

## ssl证书

我使用的是 certbot 自动获取的 Let\&#8217;s Encrypt 证书

安装 certbot

    sudo apt-get update -y
    sudo apt-get install software-properties-common
    sudo add-apt-repository ppa:certbot/certbot
    sudo apt-get update -y
    sudo apt-get install python-certbot-nginx -y
    

使用

    sudo certbot --nginx

Let\&#8217;s Encrypt 证书 有效期很短 但是certbot可以一键更新

    certbot renew 

添加到cron自动任务就可以自动更新证书了

还有如果想测试下更新用这个指令

    sudo certbot renew --dry-run

## 最终配置文件

    proxy_cache_path /usr/local/data/nginx_cache levels=1:2 keys_zone=tmp-nuget:100m inactive=7d max_size=10g;
    server {
            listen 80;
            #监听端口#
            server_name nuget.luodaoyi.com;
            #设置server name#
            charset utf-8;
            #设置字符编码为utf-8,可根据实际情况调整#
            location / {
                    proxy_cache tmp-nuget;
                    proxy_cache_valid  200 206 304 301 302 1d;
                    proxy_cache_valid any 1d;
                    proxy_cache_key $host$uri$is_args$args;
                    add_header X-Via $server_addr;
                    add_header X-Cache $upstream_cache_status;
                    proxy_redirect off;
                    proxy_pass https://www.nuget.org;
                    proxy_set_header Host www.nuget.org;
                    proxy_set_header User-Agent $http_user_agent;
                    proxy_set_header Referer https://www.nuget.org;
                    proxy_set_header Accept-Encoding "";
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    subs_filter "www.nuget.org" "nuget.luodaoyi.com";
                    subs_filter "api.nuget.org" "api.nuget.luodaoyi.com";
                    subs_filter_types text/css text/xml text/javascript;
            }
            listen 443 ssl http2; # managed by Certbot
            ssl_certificate /etc/letsencrypt/live/nuget.luodaoyi.com/fullchain.pem; # managed by Certbot
            ssl_certificate_key /etc/letsencrypt/live/nuget.luodaoyi.com/privkey.pem; # managed by Certbot
            include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    }
    server {
            listen 80;
            #监听端口#
            server_name api.nuget.luodaoyi.com;
            #设置server name#
            charset utf-8;
            #设置字符编码为utf-8,可根据实际情况调整#
            location / {
                    proxy_cache tmp-nuget;
                    proxy_cache_valid  200 206 304 301 302 1d;
                    proxy_cache_valid any 1d;
                    proxy_cache_key $host$uri$is_args$args;
                    add_header X-Via $server_addr;
                    add_header X-Cache $upstream_cache_status;
                    proxy_redirect off;
                    proxy_pass https://api.nuget.org/;
                    proxy_set_header Host api.nuget.org;
                    proxy_set_header User-Agent $http_user_agent;
                    proxy_set_header Referer https://api.nuget.org;
                    proxy_set_header Accept-Encoding "";
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    subs_filter "www.nuget.org" "nuget.luodaoyi.com";
                    subs_filter "api.nuget.org" "api.nuget.luodaoyi.com";
                    subs_filter_types text/css text/xml text/javascript;
            }
            listen 443 ssl http2; # managed by Certbot
            ssl_certificate /etc/letsencrypt/live/nuget.luodaoyi.com/fullchain.pem; # managed by Certbot
            ssl_certificate_key /etc/letsencrypt/live/nuget.luodaoyi.com/privkey.pem; # managed by Certbot
            include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
            ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
    }
    

## 我的nuget

nuget:

    https://nuget.luodaoyi.com

nuget api:

    https://api.nuget.luodaoyi.com

 [1]: /uploads/oss/2017-11-28-2.png "2"