---
title: "Debian, Ubuntu, LinuxMint 安裝 MySQL 5.7, 5.6, 5.5"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "Debian, Ubuntu, LinuxMint 安裝 MySQL 57, 56, 55-debianubuntulinuxmint安裝mysql575655"
date: "2017-03-12 06:31:09"
---



以下會示範在 Debian, Ubuntu 及 LinuxMint 分別安裝 MySQL 5.7, 5.6, 5.5 的方法。

首先按照需要的安裝的 MySQL 版本, 加入相應的 Repository, 然後用 apt-get 安裝 MySQL:

1+ MySQL 5.7

    $ sudo apt-get install software-properties-common
    $ sudo add-apt-repository -y ppa:ondrej/mysql-5.7

2+ MySQL 5.6

    $ sudo apt-get install software-properties-common
    $ sudo add-apt-repository -y ppa:ondrej/mysql-5.6

3+ MySQL 5.5

    $ sudo apt-get install software-properties-common
    $ sudo add-apt-repository -y ppa:ondrej/mysql-5.5

然後就用 apt-get 安裝 MySQL

    $ sudo apt-get update
    $ sudo apt-get install mysql-server

安裝時 MySQL 會詣問要設置的 root 新密碼, 或者可以執行 mysql\_secure\_installation 修改:

    $ sudo mysql_secure_installation

如果可以連接 MySQL 便安裝完成了, 啟動 MySQL Server:

     sudo service mysql start

接著可以嘗試連接 MySQL, 如果可以成功連接, 那便完成安裝及設置了。

     mysql -u root -p