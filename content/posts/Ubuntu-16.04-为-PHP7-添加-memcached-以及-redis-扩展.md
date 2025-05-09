---
title: "Ubuntu 16.04 为 PHP7 添加 memcached 以及 redis 扩展"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "Ubuntu 1604 为 PHP7 添加 memcached 以及 redis 扩展-ubuntu1604为php7添加memcached以及redis扩展"
date: "2017-03-12 06:29:41"
---



切换到 PHP 7 之后，网站的速度大幅提升，不过通常的扩展可能某一个就还没有支持 PHP7

# Memcached

比如说我现在使用了最新的 Ubuntu 16.04，虽然内置了 PHP 7 源，但 memcached 就还没有，不过好在，它已经支持了 PHP 7 ，只是没有源而已，我们手动编译它。

要安装 memcached，需要先安装依赖库 `libmemcached`

从[这里][1]找到最新的 libmemcached 源码包，然后下载

    wget https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
    tar -zxf libmemcached-1.0.18.tar.gz
    cd libmemcached-1.0.18/
    ./configure
    make
    make install

安装好依赖库之后，我们来安装 memcached ：

从 github 克隆 memcached 后，需要手动切换到 php7 分支，不然会提示  
`fatal error: ext/standard/php_smart_str.h: No such file or directory` 错误.

    git clone https://github.com/php-memcached-dev/php-memcached.git
    cd php-memcached/
    git checkout php7
    phpize
    ./configure --disable-memcached-sasl
    make
    make install

# Redis

同样的，Redis其实也已经有了 PHP 7 版本，我们从 github 上获取项目克隆，然后手动切换到 php7 分支即可：

    git clone https://github.com/phpredis/phpredis.git
    cd phpredis/
    git checkout php7
    phpize
    ./configure
    make
    make install

# 启动扩展

光安装了还不够，我们还需要编辑PHP的配置文件来使扩展被加载才行，  
`vi /etc/php/7.0/fpm/php.ini` ，在配置文件中添加如下语句：

    extension=memcached.so
    extension=redis.so

最后使用命令来重启 PHP 服务： `service php7.0-fpm restart`

 [1]: https://launchpad.net/libmemcached/+download