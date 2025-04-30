---
title: "Mysql常用命令"
categories: [ "数据库" ]
tags: [ "develop" ]
draft: false
slug: "Mysql常用命令-mysql常用命令"
date: "2017-03-12 06:29:20"
---



# 导入sql文件

在MySQL命令行中中直接导入*.sql脚本，在mysql中执行sql文件的命令：

    mysql> source   /root/db.sql;

# 增加用户

格式：

    grant select on 数据库.* to 用户名@登录主机 identified by "密码" 

例1、

    增加一个用户`test1`密码为`abc`，让他可以在任何主机上登录，并对所有数据库有查询、插入、修改、删除的权限。
    首先用以root用户连入MYSQL，然后键入以下命令：

    grant select,insert,update,delete on *.* to test2@localhost identified by "abc";

如果你不想test2有密码，可以再打一个命令将密码消掉。

    grant select,insert,update,delete on mydb.* to test2@localhost identified by "";

# 显示命令

## 显示数据库列表：

    show databases; 

刚开始时才两个数据库：mysql和test。mysql库很重要它里面有MYSQL的系统信息，我们改密码和新增用户，实际上就是用这个库进行操作。

## 显示库中的数据表：

     use mysql； //打开库    show tables;

## 显示数据表的结构：

     describe 表名;

## 建库：

    create database 库名;

## 建表：

    use 库名；     create table 表名 (字段设定列表)；

## 删库和删表:

    drop database 库名;
    drop table 表名；

## 将表中记录清空：

    delete from 表名;

## 显示表中的记录：

    select * from 表名;

# 导出数据

    mysqldump -u 用户名 -p 数据库名 > 存放位置
    exp:
    mysqldump -u root -p test > c:/a.sql

# MySQL导出导入命令的用例

  1. 导出整个数据库

    mysqldump -u 用户名 -p 数据库名 > 导出的文件名
    mysqldump -u wcnc -p smgp_apps_wcnc > wcnc.sql
    mysqldump -u root -p typecho_blog > typecho_blog.sql

  1. 导出一个表

    mysqldump -u 用户名 -p 数据库名表名> 导出的文件名
    mysqldump -u wcnc -p smgp_apps_wcnc users> wcnc_users.sql
    

  1. 导出一个数据库结构

    mysqldump -u wcnc -p -d --add-drop-table smgp_apps_wcnc >d:wcnc_db.sql
    -d 没有数据 --add-drop-table 在每个create语句之前增加一个drop table

  1. 导入数据库  
    常用source 命令

进入mysql数据库控制台,  
如

    mysql -u root -p
    mysql>use 数据库
    然后使用source命令,后面参数为脚本文件(如这里用到的.sql)
    mysql>source d:wcnc_db.sql