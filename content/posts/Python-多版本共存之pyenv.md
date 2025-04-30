---
title: "Python 多版本共存之pyenv"
categories: [ "python" ]
tags: [ "python" ]
draft: false
slug: "Python 多版本共存之pyenv-python多版本共存之pyenv"
date: "2017-11-24 11:28:00"
---



经常遇到这样的情况：

  * 系统自带的 Python 是 2.6，自己需要 Python 2.7 中的某些特性；
  * 系统自带的 Python 是 2.x，自己需要 Python 3.x；

此时需要在系统中安装多个 Python，但又不能影响系统自带的 Python，即需要实现  
Python 的多版本共存。[pyenv][1] 就是这样一个 Python 版本管理器。

## 安装 pyenv

在终端执行如下命令以安装 pyenv 以及几个插件：

    $ curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
    $ echo "export PYENV_ROOT="$HOME/.pyenv"">> ~/.bashrc
    $ echo "export PATH="$PYENV_ROOT/bin:$PATH"">> ~/.bashrc
    $ echo "eval "$(pyenv init -)"" >> ~/.bashrc
    $ echo "eval "$(pyenv virtualenv-init -)"" >> ~/.bashrc
    $ exec $SHELL -l

## 安装 Python

### 查看可安装的版本

    $ pyenv install --list

该命令会列出可以用 pyenv 安装的 Python 版本，仅列举几个:

    2.7.8   # Python 2 最新版本
    3.4.1   # Python 3 最新版本
    anaconda-4.0.0  # 支持 Python 2.6 和 2.7
    anaconda3-4.0.0 # 支持 Python 3.3 和 3.4
    

其中形如 `x.x.x` 这样的只有版本号的为 Python 官方版本，其他的形如 `xxxxx-x.x.x`  
这种既有名称又有版本后的属于 “衍生版” 或发行版。

### 安装 Python 的依赖包

在安装 Python 时需要首先安装其依赖的其他软件包，已知的一些需要预先安装的库如下。

在 CentOS/RHEL/Fedora 下:

    sudo yum install readline readline-devel readline-static
    sudo yum install openssl openssl-devel openssl-static
    sudo yum install sqlite-devel
    sudo yum install bzip2-devel bzip2-libs
    

在 Ubuntu下：

    sudo apt-get update
    sudo apt-get install make build-essential libssl-dev zlib1g-dev
    sudo apt-get install libbz2-dev libreadline-dev libsqlite3-dev wget curl
    sudo apt-get install llvm libncurses5-dev libncursesw5-dev
    

### 安装指定版本

使用如下命令即可安装 python 3.4.1：

    $ pyenv install 3.4.1 -v

该命令会从 github 上下载 python 的源代码，并解压到 `/tmp` 目录下，然后在  
`/tmp` 中执行编译工作。  
若依赖包没有安装，则会出现编译错误，需要在安装依赖包后重新执行该命令。

如果网络不太好，用 pyenv 下载会比较慢，可以先执行该命令，然后到 `~/.pyenv/cache`  
目录下查看要下载的文件的文件名，然后自己到官方网站下载，并将文件放在 `~/.pyenv/cache`  
目录下。pyenv 会检查文件的完整性，若确认无误，则不会再重新下载。

对于科研环境，更推荐安装专为科学计算准备的 Anaconda 发行版，  
`pyenv install anaconda-4.0.0` 安装 Python 2.x 版本，  
`pyenv install anaconda3-4.0.0` 安装 Python 3.x 版本；

### 更新数据库

安装完成之后需要对数据库进行更新：

    $ pyenv rehash

### 查看当前已安装的 python 版本

    $ pyenv versions
    * system (set by /home/seisman/.pyenv/version)
    3.4.1

其中的星号表示当前正在使用的是系统自带的 python。

### 设置全局的 python 版本

    $ pyenv global 3.4.1
    $ pyenv versions
    system
    * 3.4.1 (set by /home/seisman/.pyenv/version)

当前全局的 python 版本已经变成了 3.4.1。也可以使用 `pyenv local` 或 `pyenv shell`  
临时改变 python 版本。

### 确认 python 版本

    $ python
    Python 3.4.1 (default, Sep 10 2014, 17:10:18)
    [GCC 4.4.7 20120313 (Red Hat 4.4.7-1)] on linux
    Type "help", "copyright", "credits" or "license" for more information.
    >>>

## 使用 python

  * 输入 `python` 即可使用新版本的 python；
  * 系统自带的脚本会以 `/usr/bin/python` 的方式直接调用老版本的 python，
    
        因而不会对系统脚本产生影响；

  * 使用 `pip` 安装第三方模块时会安装到 `~/.pyenv/versions/3.4.1` 下，
    
        不会和系统模块发生冲突。

  * 使用 `pip` 安装模块后，可能需要执行 `pyenv rehash` 更新数据库；

## 使用 USTC 镜像

如果使用 pip 安装模块时速度比较慢，可以考虑使用中科大 LUG 提供的镜像，可以大大提供 pip 安装模块的速度。

编辑 `~/.pip/pip.conf` 文件（如果没有则创建之），将 `index-url` 开头的一行修改为下面一行：

    [global]
    index-url = https://pypi.mirrors.ustc.edu.cn/simple
    

## 安装pyenv-virtualenv

pyenv-virtual是pyenv的插件，它支持管理多个virtualenv

    git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
    echo "eval "$(pyenv virtualenv-init -)"" >> ~/.bashrc

### 创建virtualenv

    pyenv virtualenv 3.5.1 aiohttp-virtual-env

  * 创建aiohttp-virtual-env之前，须先安装Python 3.5.1（通过系统或pyenv安装）。
  * aiohttp-virtual-env存储在~/.pyenv/versions/3.5.1/envs目录中，且在~/.pyenv/versions目录中建立同名符号链接。

### 删除virtualenv

    pyenv uninstall aiohttp-virtual-env

### 列出virtualenv

    pyenv virtualenvs

### 激活/禁用virtualenv

    pyenv activate aiohttp-virtual-env
    pyenv deactivate

## 配置Upstart脚本

若python程序须要通过Upstart启动，则其Upstart脚本可以类似：

    # service name
    description "service description ..."
    respawn
    setuid
    setgid
    env PYENV_ROOT=/home//.pyenv
    env PATH=/home//.pyenv/bin:/sbin:/usr/sbin:/bin:/usr/bin
    env PYENV_VERSION=
    chdir
    script
            eval "$(pyenv init -)"
            exec ./
    end script
    # vim: ts=4 sw=4 sts=4 ft=upstart

或

    # service name
    description "service description ..."
    respawn
    setuid
    setgid
    env PYENV_ROOT=/home//.pyenv
    env PATH=/home//.pyenv/shims:/home//.pyenv/bin:/sbin:/usr/sbin:/bin:/usr/bin
    env PYENV_VERSION=
    chdir
    exec ./
    # vim: ts=4 sw=4 sts=4 ft=upstart

  * `username`为服务运行的用户名，通常为`PYENV_ROOT`所属用户
  * `group`为服务运行的组名，通常为`PYENV_ROOT`所属组。
  * `PYENV_VERSION`为Python版本号或`virtualenv`的名字。
  * `app dir`为Python程序的目录。
  * `app`为Python程序或启动脚本。

## 参考

  1. 
  2. 
  3. 

## 修订历史

  * 2013-10-04：初稿；
  * 2014-10-07：将 Python 依赖包一段的位置提前；
  * 2016-07-30：使用 `pyenv-installer` 安装；
  * 2016-10-19：中科大 pypi 镜像；
  * 2017-11-24: 增加`pyenv-virtualenv` 说明和Upstart脚本

 [1]: https://github.com/yyuu/pyenv