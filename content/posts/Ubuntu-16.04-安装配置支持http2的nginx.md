---
title: "Ubuntu 16.04 安装配置支持http2的nginx"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "Ubuntu 1604 安装配置支持http2的nginx-ubuntu1604安装配置支持http2的nginx"
date: "2017-03-12 06:30:51"
---



# 第一步 安装最新版本的nginx

对于ubuntu16.04而言 直接装就是最新的

    sudo apt-get update
    sudo apt-get install nginx
    

查看Nginx版本

    sudo nginx -v

16.04默认应该是

    nginx version: nginx/1.10.0 (Ubuntu)

# 第二部 修改服务器配置

配置文件`/etc/nginx/sites-available/default`

    server_name example.com;

保存修改后的文件  
使用命令`nginx -t`检查配置文件语法是否正确

如果正确 会输出

    nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
    nginx: configuration file /etc/nginx/nginx.conf test is successful

不正确的话根据提示 找原因

# 4添加ssl证书

创建ssl证书存放的目录

    sudo mkdir /etc/nginx/ssl

拷贝站点的证书到指定目录

    sudo cp /path/to/your/certificate.crt /etc/nginx/ssl/example.com.crt
    sudo cp /path/to/your/private.key /etc/nginx/ssl/example.com.key

现在让我们打开站点配置文件 并添加ssl证书配置

    sudo vim /etc/nginx/sites-available/default

在`server`节点中新起一行 配置证书路径

    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;

# 5 配置安全选项

HTTP / 2有一个巨大的黑名单的旧的和不安全的密码，所以我们要避开他们。密码套件是一堆的加密算法，它描述了如何传输数据应该被加密。  
我们将使用一个非常受欢迎的密码设置，其安全性是由互联网巨头像CloudFlare的批准。不允许使用MD5加密的（这被称为不安全的1996起，但尽管如此，它的使用非常广泛，甚至到今天）

打开配置文件

`sudo vim /etc/nginx/nginx.conf`

添加下面配置到`ssl_prefer_server_ciphers on;`后面

    ssl_ciphers EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;

检查nginx语法

    sudo nginx -t

# 6增加密钥交换的安全性

建立一个安全连接的第一步是服务器和客户端之间的私有密钥的交换。问题是，到这一点上，他们之间的连接是不加密的，这意味着数据传输是可见的任何第三方。这就是为什么我们需要性–Hellman–Merkle算法。关于它是如何工作的技术细节是不能一言以蔽之解释一个复杂的问题，但如果你真的有兴趣的细节，你可以看这个视频。

默认情况下，nginx使用一个1028位的他（Ephemeral Diffie Hellman）的关键，这是比较容易解密。提供最大的安全性，我们要建立我们自己的、更安全的DHE的关键。  
要做到这一问题，发出以下命令：

    sudo openssl dhparam -out /etc/nginx/ssl/dhparam.pem 2048

> 记住，我们要生成DH参数在同一文件夹中我们的SSL证书。在本教程中，证书在/ etc / Nginx / SSL /。这是因为nginx看起来总是为用户提供密钥证书的文件夹和远程使用它如果存在。

文件路径后的变量（在我们的情况下，它是2048）指定的键的长度。以一个2048位的长度是足够安全和Mozilla基金会的推荐，但如果你正在寻找更加密，你可以改变它4096。  
生成过程将需要约5分钟

一旦完成，再次打开默认的nginx配置文件：

    sudo vim /etc/nginx/sites-available/default

添加新的配置在 `server`块中

    ssl_dhparam  /etc/nginx/ssl/dhparam.pem;

# 7重定向httpp请求到https

在配置文件`/etc/nginx/sites-available/default`中加入新server节点

    server {
           listen         80;
           listen    [::]:80;
           server_name    example.com;
           return         301 https://$server_name$request_uri;
    }

保存后检查语法是否正确

    sudo nginx -t

# 8重启nginx

要想使之前的配置全部生效 需要重启nginx  
首先站点配置文件看起来像是这样

    server {
            listen 443 ssl http2 default_server;
            listen [::]:443 ssl http2 default_server;
            root /var/www/html;
            index index.html index.htm index.nginx-debian.html;
            server_name example.com;
            location / {
                    try_files $uri $uri/ =404;
            }
            ssl_certificate /etc/nginx/ssl/example.com.crt;
            ssl_certificate_key /etc/nginx/ssl/example.com.key;
            ssl_dhparam /etc/nginx/ssl/dhparam.pem;
    }
    server {
           listen         80;
           listen    [::]:80;
           server_name    example.com;
           return         301 https://$server_name$request_uri;
    }

重启Nginx

    sudo systemctl restart nginx
    或者
    sudo service nginx restart

# 9验证配置

让我们检查我们的服务器是否正在运行。打开Web浏览器并导航到您的域（与你的实际域名example.com替换）：

    example.com

打开chrome设置  
`(View -> Developer -> Developer Tools)`  
刷新当前页面

切换到`Network` tab 点击表格头 启用`Protocol` 选项

现在你应该可以看到`h2`which stands for HTTP/2)

# 10配置nginx性能

在这一步，我们将调整为最佳性能和安全性的主要nginx配置文件

打开配置文件`nginx.conf`

    sudo vim /etc/nginx/nginx.conf

## 启用连接凭据缓存

相比于HTTP，HTTPS需要相对长的时间来建立服务器和用户之间的初始连接。为了尽量减少页面加载速度中的这种差异，我们将启用连接凭据的缓存。这意味着，而不是创建一个新的会话在每一个页面上的请求，服务器将使用缓存版本的凭据，而不是。

启用会话缓存 ，添加如下的行到配置文件的`http`块中

    ssl_session_cache shared:SSL:5m;
    ssl_session_t
    imeout 1h;

`ssl_session_cache`指定缓存将包含会话信息的大小。1字节的它可以存储约4000个会话的信息。对于大多数用户来说，5个宏的默认值将是足够的，但如果你期望的流量真的很重，你可以相应地增加这个值。  
`ssl_session_timeout`限制特定会话缓存中存储的时间。这个值不应该太大（超过一个小时），但设置值太低是没有意义的。

## 启用HTTP严格传输安全（HSTS）

尽管我们已经做了所有常规的HTTP请求重定向到HTTPS在nginx的配置文件中，我们还应该启用HTTP严格传输安全避免首先要做那些重定向  
如果浏览器找到HSTS报头，它不会试图通过普通的HTTP再次为给定的时间内连接到服务器。不管是什么，它将只使用加密的HTTPS连接交换数据。这个标题也应该保护我们的协议降级攻击。

将下面的配置添加到`nginx.conf`的http节点中

    add_header Strict-Transport-Security "max-age=15768000" always;

`max-age`单位使秒。15768000秒相当于6个月。

默认情况下，此头不添加到域的请求。如果你想申请的子域，HSTS的所有的人，你应该在行尾添加includeSubDomains变量，像这样：

    add_header Strict-Transport-Security "max-age=15768000; includeSubDomains: always;";

保存 检查配置

`nginx -t`

重启  
`servier nginx restart`