---
title: "使用LNMP环境安装typecho博客的全程记录"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "使用LNMP环境安装typecho博客的全程记录-使用lnmp环境安装typecho博客的全程记录"
date: "2017-03-12 06:32:15"
---



虽然我是搞asp.net的 但是十分欣赏php，php有很多开源的博客程序 比如大名鼎鼎的[WordPress][1].还有各种独立博客大牛使用的[z-blog][2],以及短小精悍的[emblog][3]。 

wordpress臃肿不堪，pass！其他的不喜欢，所以就选择国人开发的typecho开源博客系统，优点就是简单好用，支持[markdown][4]。  
安装typecho需要php环境，这里我使用的是[lnmp][5]，服务器采用[Vultr][6]乞丐版，系统是ubuntu14.14，下面开始安装,每一步都有详细介绍

    #升级各种软件包
    sudo apt-get update
    #安装screen 防止长时间编译时ssh断开连接
    sudo apt-get install screen
    #开启新screen窗口
    screen -S lnmp
    #下载并安装lnmp一键包 因为我的服务器在国内所以用的lnmp国内的下载点
    wget -c https://api.sinas3.com/v1/SAE_lnmp/soft/lnmp1.2-full.tar.gz --no-check-certificate && tar zxf lnmp1.2-full.tar.gz && cd lnmp1.2-full && ./install.sh lnmp
    # 按照提示一步一步安装好即可-mysql超级密码，是否启用innoDB,Mysql版本,php版本，完成后就是长时间的等待编译完成了，时间比较长 30分钟到1小时不等，看VPS的配置
    # 上一部完成后 添加虚拟主机
    lnmp vhost add
    # 输入域名 www.luodaoyi.com，
    www.luodaoyi.com
    # 设置伪静态规则，lnmp一键包已经内置了typecho的支持 所以只需要输入 typecho即可，它会自定Incloud Typecho的伪静态配置
    typecho
    # 创建mysql数据库 这就不说了 按照提示来
    #然后我们的虚拟主机就配置好了

这还没完，还得重新配置下伪静态文件，否则typecho会404.。

    vi /usr/local/nginx/conf/vhost/www.luodaoyi.com.conf
    主要有两点
    #注释掉  try_files $uri =404;
    #启用    include pathinfo.conf;
    看起来是这样：
    server
        {
        listen 80;
            #listen [::]:80;
            server_name www.luodaoyi.com;
            index index.php;
            root  /home/wwwroot/www.luodaoyi.com;
            include typecho.conf;
            #error_page   404   /404.html;
            location ~ [^/]\.php(/|$)
            {
                # comment try_files $uri =404; to enable pathinfo
                #try_files $uri =404;
                fastcgi_pass  unix:/tmp/php-cgi.sock;
                fastcgi_index index.php;
                include fastcgi.conf;
                include pathinfo.conf;
            }
            location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
            {
                expires      30d;
            }
            location ~ .*\.(js|css)?$
            {
                expires      12h;
            }
            access_log  /home/wwwlogs/www.luodaoyi.com.log  access;
        }

然后就可以上传typecho的代码开始安装了，具体不再复述

启用https:  
方法有两种  
方法1 ：直接在服务器的nginx配置好ssl证书，并启用443端口，想要http连接全部跳转到Https的话，继续编辑nginx的vhost配置

    vi /usr/local/nginx/conf/vhost/www.luodaoyi.com.conf
    #添加新80端口server 设置好跳转：
    server
        {
            listen 80;
            server_name www.luodaoyi.com;
            rewrite ^(.*)$  https://$host$1 permanent;
        }
    设置好以后所有的http请求会重定向到https

方法2：使用支持https加速的cdn，我用的[又拍云][7],在工具箱中配置好SSL服务，注意这里的ssl证书必须上传私钥，并且私钥不能用密码加密过，否则会失败，然后绑定你的CDN服务域名即可。我的就是用的是方法1加这种方法

 [1]: https://wordpress.org/
 [2]: https://www.zblogcn.com/
 [3]: http://www.emlog.net/
 [4]: https://www.luodaoyi.com/zatan/5.html
 [5]: http://lnmp.org/
 [6]: https://www.luodaoyi.com/link-vultr.html/
 [7]: https://www.upyun.com