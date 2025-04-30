---
title: "Ubuntu下的OpenResty 安装"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "Ubuntu下的OpenResty 安装-ubuntu下的openresty安装"
date: "2017-03-12 06:22:06"
---



## 安装前的准备

您必须将这些库 perl 5.6.1+, libreadline, libpcre, libssl安装在您的电脑之中。 对于 Linux来说, 您需要确认使用 ldconfig 命令，让其在您的系统环境路径中能找到它们。

### Debian 和 Ubuntu 用户

推荐您使用 apt-get安装以下的开发库:

    apt-get install libreadline-dev libncurses5-dev libpcre3-dev \
        libssl-dev perl make build-essential

### Fedora 和 RedHat 用户

推荐您使用yum安装以下的开发库:

    yum install readline-devel pcre-devel openssl-devel gcc

### Mac OS X (Darwin) 用户

推荐您使用一些软件管理工具先安装PCRE, 比如说[Homebrew][1]

    brew update
    brew install pcre openssl

当然了，您也可以直接通过代码安装 PCRE 和 OpenSSL.

安装好 PCRE 和 OpenSSL 之后，可以使用下面的命令进行安装：

    $ ./configure \
       --with-cc-opt="-I/usr/local/opt/openssl/include/ -I/usr/local/opt/pcre/include/" \
       --with-ld-opt="-L/usr/local/opt/openssl/lib/ -L/usr/local/opt/pcre/lib/" \
       -j8

## 构建 OpenResty

### 下载

从下载页 [Download][2]下载最新的ngx_openresty源码包，并且像下面的示例一样将其解压:

    tar xzvf ngx_openresty-VERSION.tar.gz

VERSION 的地方替换成您下载的源码包的版本号，比如说 0.8.54.6。

### ./configure

然后在进入 ngx_openresty-VERSION/ 目录, 然后输入以下命令配置:

    ./configure

默认, &#8211;prefix=/usr/local/openresty 程序会被安装到/usr/local/openresty目录。

您可以指定各种选项，比如

    ./configure --prefix=/opt/openresty \
                --with-luajit \
                --without-http_redis2_module \
                --with-http_iconv_module \
                --with-http_postgres_module

试着使用 ./configure &#8211;help 查看更多的选项。

配置文件（./configure script）运行出错可以到 build/nginx-VERSION/objs/autoconf.err 找到。 VERSION 的地方必须与OpenResty版本号相对应, 比如 0.8.54.6。

make  
您可以使用下面的命令来编译：

make  
如果您的电脑支持多核 make 工作的特性, 您可以这样编译:

make -j2  
假设您是的机器是双核。

make install  
如果前面的步骤都没有问题的话,您可以使用下面的命令安装l OpenResty到您的系统之中：

make install  
在 Linux,通常包括 sudo来执行root权限做的事情。

 [1]: http://mxcl.github.com/homebrew/
 [2]: https://openresty.org/cn/download.html