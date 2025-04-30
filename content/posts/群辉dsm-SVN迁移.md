---
title: "群辉dsm SVN迁移"
categories: [ "工具" ]
tags: [ "工具","SVN" ]
draft: false
slug: "群辉dsm SVN迁移-群辉dsmsvn迁移"
date: "2017-09-21 13:18:00"
---



公司买了群辉nas服务器，用来备份数据和代码  
之前的svn服务器用的windows，出现过数据丢失的问题，并且不够可靠。所以迁移到了nas的svn服务器  
折腾了一下午，折腾出来几个方案

## svn dump方案

此方案是最慢的方案，起初用了此方案，导出了只有700多次提交的一个svn仓库。  
最后结论是 导出满，导入他妈的更慢。并且库下面的passd和authz不会被一起导出，所以要重新配置  
导出:

  * 全备份：

    # 压缩备份
    sudo svnadmin dump /path/repository | sudo gzip > /path/repository-backup.gz.2017-09-21
    # 不压缩备份
    sudo svnadmin dump /path/repository > /path/repository-backup.2017-09-21

  * 只备份指定的子目录  
    1、 导出整个库
    
        svnadmin dump /path/repository > /path/repository-backup.2017-03-28
        
    
    2、从备份文件中过滤出要导出的目录(可以过滤多个目录)
    
        cat /path/repository-backup.2017-03-28 | svndumpfilter  include /projects > /path/projects-backup.2017-03-28
        
    
    3、选择是否压缩

    gzip /path/projects-backup.2017-03-28

注意: `projects`目录必须是没有`rename`的目录，如果是`rename`后的目录，则导出的文件都是空记录，使用`rename`前的目录名导出的备份还是`rename`前的。  
为了正确导出`rename`后的文件，假如`rename`前的目录名为`apple`，步骤2改为`include/projects/apple`，这样就可以导出`rename`后的文件了。

## 仓库迁移

直接压缩整个仓库文件夹传到nas上面解压即可，经过测试 群辉nas的svn是通过读取文件夹下的目录来确定几个仓库的，并且读取仓库下的配置文件来确定用户权限以及账户密码之类的

在win下使用7zip压缩

    7z a test.zip f:/test/** # 压缩文件夹

上传至群辉直接解压即可

## 仓库合并

  * 在目的服务器上创建一个主仓库 /path/main_repository
  * 在本地checkout目的服务器的主仓库
  * 如果需要将迁移的仓库存储到SVN中指定的目录`A` 下，则在本地创建这个指定的目录`A`，并用svn工具提交到目的服务器。然后登录目的服务器：

    # 解压缩合并
    sudo zcat /home/repository-backup.gz.2017-03-28 | sudo svnadmin load /path/main_repository --parent-dir A
    # 不解压缩合并
    sudo svnadmin load /path/main_repository --parent-dir A  < /home/repository-backup.2017-03-28
    

参数 `--parent-dir` 是指定版本库`main_repository`下的具体路径，这里是第一级目录`A`.

  * 如果不用迁移到指定目录下，只需要迁移到根目录下，则登录目的服务器：

        # 解压缩合并
    sudo zcat /home/repository-backup.gz.2017-03-28 | sudo svnadmin load /path/main_repository
        # 不解压缩合并
    sudo svnadmin load /path/main_repository < /home/repository-backup.2017-03-28
    

这样就可以将多个仓库合并成一个仓库了。

## 仓库恢复

  * 如果仓库遇到不可修复的问题或者内容够乱，需要恢复到以前备份的仓库。
  * 使用FTP等工具，将备份的文件传输到需要恢复的服务器上，例如 /home目录下
  * 登录需要恢复的服务器

    # 建立新的svn仓库
    sudo svnadmin create /path/new_repository
    # check
    ls -l /path/new_repository
    # 赋予组成员对所有新加入文件仓库的文件拥有相应的权限
    sudo chmod -R g+rws /path/new_repository
    # 导入没压缩数据
    sudo svnadmin load /path/new_repository < /home/repository-backup.2017-03-28
    # 导入被压缩数据
    sudo zcat /home/repository-backup.gz.2017-03-28 | sudo svnadmin load /path/new_repository
    # 删除旧仓库
    sudo rm -r /path/main_repository
    # 修改新仓库名
    sudo mv /path/new_repository /path/main_repository
    # 修改权限
    sudo chown -R www-data:subversion /path/main_repository

如果是清空svn仓库，则只要去掉导入的步骤就可以了。

## 参考

<https://tmyam.github.io/blog/2017/03/28/svncang-ku-qian-yi-he-he-bing/>  
<http://www.jianshu.com/p/295b423d50ad>  
<http://blog.chinaunix.net/uid-10449864-id-3048714.html>  
<http://blog.chinaunix.net/uid-725717-id-3147440.html>  
<http://blog.liuxianan.com/windows-cmd-zip.html>