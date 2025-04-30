---
title: "Ubuntu安装最新版nginx"
categories: [ "linux" ]
tags: [ "linux","ubuntu" ]
draft: false
slug: "Ubuntu安装最新版nginx-ubuntu安装最新版nginx"
date: "2017-12-29 03:08:00"
---



![][1]

众所周知，Ubuntu 上官方源的更新速度一直是慢得令人发指的，很多人不得不自己编译 nginx，非常麻烦。

所以。我们直接用nginx官方源来安装。

## 增加源地址:

    sudo vim /etc/apt/sources.list    

增加nginx官方源地址:

    deb http://nginx.org/packages/mainline/ubuntu/ xenial nginx
    deb-src http://nginx.org/packages/mainline/ubuntu/ xenial nginx

## 导入key

    cd
    wget http://nginx.org/keys/nginx_signing.key
    sudo apt-key add nginx_signing.key

## 卸载旧版本

    sudo apt remove nginx nginx-common nginx-full nginx-core
    

## 安装官方最新版

    sudo apt update
    sudo apt install nginx
    

## 开启服务和设置开启启动

    sudo systemctl enable nginx
    sudo systemctl start nginx

查看下状态:

    systemctl status nginx

![][2] 

## 设置执行进程的用户账户

打开 `/etc/nginx/nginx.conf` 文件，发现第一行就是进程用户:`nginx`  
![][3] 

这里改成`www-data`

搞定

## 修改Nginx 全局配置

    http {
        include            mime.types;
        default_type       application/octet-stream;
        log_format  main  "$remote_addr - $remote_user [$time_local] "$request" "
                          "$status $body_bytes_sent "$http_referer" "
                          ""$http_user_agent" "$http_x_forwarded_for"";
        access_log  /var/log/nginx/access.log  main;
        charset            UTF-8;
        sendfile           on;
        tcp_nopush         on;
        tcp_nodelay        on;
        keepalive_timeout  60;
        gzip               on;
        gzip_vary          on;
        gzip_comp_level    6;
        gzip_buffers       16 8k;
        gzip_min_length    1000;
        gzip_proxied       any;
        gzip_disable       "msie6";
        gzip_http_version  1.0;
        gzip_types         text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript image/svg+xml;
       include /etc/nginx/conf.d/*.conf;
    }

## 站点配置模板

    server {
        listen               443 ssl http2 fastopen=3 reuseport;
        # 如果你使用了 Cloudflare 的 HTTP/2 + SPDY 补丁，记得加上 spdy
        # listen               443 ssl http2 spdy fastopen=3 reuseport;
        server_name          www.imququ.com imququ.com;
        server_tokens        off;
        include              /home/jerry/www/nginx_conf/ip.blacklist;
        # https://imququ.com/post/certificate-transparency.html#toc-2
        ssl_ct               on;
        ssl_ct_static_scts   /home/jerry/www/scts;
        # 中间证书 + 站点证书
        ssl_certificate      /home/jerry/www/ssl/chained.pem;
        # 创建 CSR 文件时用的密钥
        ssl_certificate_key  /home/jerry/www/ssl/domain.key;
        # openssl dhparam -out dhparams.pem 2048
        # https://weakdh.org/sysadmin.html
        ssl_dhparam          /home/jerry/www/ssl/dhparams.pem;
        # https://github.com/cloudflare/sslconfig/blob/master/conf
        ssl_ciphers                EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
        # 如果启用了 RSA + ECDSA 双证书，Cipher Suite 可以参考以下配置：
        # ssl_ciphers              EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
        ssl_prefer_server_ciphers  on;
        ssl_protocols              TLSv1 TLSv1.1 TLSv1.2;
        ssl_session_cache          shared:SSL:50m;
        ssl_session_timeout        1d;
        ssl_session_tickets        on;
        # openssl rand 48 > session_ticket.key
        # 单机部署可以不指定 ssl_session_ticket_key
        ssl_session_ticket_key     /home/jerry/www/ssl/session_ticket.key;
        ssl_stapling               on;
        ssl_stapling_verify        on;
        # 根证书 + 中间证书
        # https://imququ.com/post/why-can-not-turn-on-ocsp-stapling.html
        ssl_trusted_certificate    /home/jerry/www/ssl/full_chained.pem;
        resolver                   114.114.114.114 valid=300s;
        resolver_timeout           10s;
        access_log                 /home/jerry/www/nginx_log/imququ_com.log;
        if ($request_method !~ ^(GET|HEAD|POST|OPTIONS)$ ) {
            return           444;
        }
        if ($host != "imququ.com" ) {
            rewrite          ^/(.*)$  https://imququ.com/$1 permanent;
        }
        location ~* (robots\.txt|favicon\.ico|crossdomain\.xml|google4c90d18e696bdcf8\.html|BingSiteAuth\.xml)$ {
            root             /home/jerry/www/imququ.com/www/static;
            expires          1d;
        }
        location ^~ /static/uploads/ {
            root             /home/jerry/www/imququ.com/www;
            add_header       Access-Control-Allow-Origin *;
            set              $expires_time max;
            valid_referers   blocked none server_names *.qgy18.com *.inoreader.com feedly.com *.feedly.com www.udpwork.com theoldreader.com digg.com *.feiworks.com *.newszeit.com r.mail.qq.com yuedu.163.com *.w3ctech.com;
            if ($invalid_referer) {
                set          $expires_time -1;
                return       403;
            }
            expires          $expires_time;
        }
        location ^~ /static/ {
            root             /home/jerry/www/imququ.com/www;
            add_header       Access-Control-Allow-Origin *;
            expires          max;
        }
        location ^~ /admin/ {
            proxy_http_version       1.1;
            add_header               Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
            # DENY 将完全不允许页面被嵌套，可能会导致一些异常。如果遇到这样的问题，建议改成 SAMEORIGIN
            # https://imququ.com/post/web-security-and-response-header.html#toc-1
            add_header               X-Frame-Options DENY;
            add_header               X-Content-Type-Options nosniff;
            proxy_set_header         X-Via            QingDao.Aliyun;
            proxy_set_header         Connection       "";
            proxy_set_header         Host             imququ.com;
            proxy_set_header         X-Real_IP        $remote_addr;
            proxy_set_header         X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_pass               http://127.0.0.1:9095;
        }
        location / {
            proxy_http_version       1.1;
            add_header               Strict-Transport-Security "max-age=31536000; includeSubDomains; preload";
            add_header               X-Frame-Options deny;
            add_header               X-Content-Type-Options nosniff;
            add_header               Content-Security-Policy "default-src "none"; script-src "unsafe-inline" "unsafe-eval" blob: https:; img-src data: https: http://ip.qgy18.com; style-src "unsafe-inline" https:; child-src https:; connect-src "self" https://translate.googleapis.com; frame-src https://disqus.com https://www.slideshare.net";
            add_header               Public-Key-Pins "pin-sha256="YLh1dUR9y6Kja30RrAn7JKnbQG/uEtLMkBgFF2Fuihg="; pin-sha256="aef6IF2UF6jNEwA2pNmP7kpgT6NFSdt7Tqf5HzaIGWI="; max-age=2592000; includeSubDomains";
            add_header               Cache-Control no-cache;
            proxy_ignore_headers     Set-Cookie;
            proxy_hide_header        Vary;
            proxy_hide_header        X-Powered-By;
            proxy_set_header         X-Via            QingDao.Aliyun;
            proxy_set_header         Connection       "";
            proxy_set_header         Host             imququ.com;
            proxy_set_header         X-Real_IP        $remote_addr;
            proxy_set_header         X-Forwarded-For  $proxy_add_x_forwarded_for;
            proxy_pass               http://127.0.0.1:9095;
        }
    }
    server {
        server_name       www.imququ.com imququ.com;
        server_tokens     off;
        access_log        /dev/null;
        if ($request_method !~ ^(GET|HEAD|POST)$ ) {
            return        444;
        }
        location ^~ /.well-known/acme-challenge/ {
            alias         /home/jerry/www/challenges/;
            try_files     $uri =404;
        }
        location / {
            rewrite       ^/(.*)$ https://imququ.com/$1 permanent;
        }
    }
    

以上配置来自于 [imququ的 本博客 Nginx 配置之完整篇][4]

 [1]: /uploads/oss/2017-12-28-15144490172324.jpg ""
 [2]: /uploads/oss/2017-12-28-15144489997255.jpg ""
 [3]: /uploads/oss/2017-12-28-15144491776259.jpg ""
 [4]: https://imququ.com/post/my-nginx-conf.html#toc-6