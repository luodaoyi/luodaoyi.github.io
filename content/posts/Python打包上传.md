---
title: "Python打包上传"
categories: [ "python" ]
tags: [ "python" ]
draft: false
slug: "Python打包上传-python打包上传"
date: "2017-03-12 06:31:39"
---



你可以用pip导出你的dependency:

    $ pip freeze > requirements.txt

然后在通过以下命令安装dependency:

    pip install -r requirements.txt

使用 setuptools 来安装  
使用 buildout 进行构建

下面具体说下这两点

  1. setuptools 的官方文档在这 setuptools &#8211; The PEAK Developers\&#8217; Center， 当然这份文档有点长，主要是用来参考。许多 python 项目里面的 setup.py 就是用的 setuptools，你在 setup.py 里面只需要写上依赖的包就 ok，当调用 setup.py install 的时候，会自动帮你把所有依赖包都装好
  2. 构建工具使用 buildout，知乎也在用这个。我曾经使用 virtualenv + pip 的组合，不过这个也还是比较麻烦的。用 buildout 的话，只需要写一个 buildout.cfg 就可以了，这个是一个 ini 格式的配置文件，一般情况下普通项目也就不到十行配置，真的很少！

你开发完成后，将你的源码打包发给别人，别人只需要下面两步就可以把你的代码依赖搞定（仅限 python 相关的，当然首先，别人得有 python）

    python bootstrap.py  # 第一次构建需要执行这个脚本来初始化，这个是buildout的初始化脚本
    bin/buildout         # 当修改了setup.py之后调用，会自动生成需要的脚本

virtualenv + pip 需要怎么做  
本地开发完后，再把代码给别人之前，需要

    pip freeze > requirements.txt

别人需要做的事情  
安装 virtualenv, virtualenvwrapper, pip  
在 .bashrc 中加入

    source path/to/virtualenvwrapper.sh
    export VENVS=path/to/virtualenv_home

开发前，需要执行下面代码

    mkvirtualenv env
    workon env
    pip install -r requirements.txt