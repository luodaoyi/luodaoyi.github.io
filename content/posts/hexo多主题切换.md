---
title: "hexo多主题切换"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "hexo多主题切换-hexo多主题切换"
date: "2017-03-12 06:33:36"
---



今天看到一个朋友在github上面的[issue][1]  
大概问题就是怎么在不同的电脑上面使用  
git有个这么个东西[Submoudle][2]中文叫做子模块

具体使用教程看这里[Git-工具-子模块][2]

这里只说怎么搞hexo多主题切换和换电脑啥的

# 开始

首先分两种情况

  1. 主题的出了配置文件 或者其他文件没有DIY过，都是直接clone原来的主题作者的
  2. 主题的CSS JS 文件自己改过

# 没有修改主题源码

如果没有修改主题源码那就按照下面的步骤来作

# 备份主题配置文件

文件在

`themes/主题名字/_config.yml`

没错就是他，如果你修改了默认的配置，就拷贝到另外的目录

# 删除主题文件

没啥说的 删除对应的主题文件，也可以直接删除themes文件夹

# 建立子模块

在主目录执行下面命令

`git submodule add <主题的git地址> themes/<主题名字>`

添加完之后 会在主git目录下面生成一个.gitmoudles文件

# 获得主题文件

执行完上面的步骤之后主题并不会自动clone到对应的目录  
要clone到本地 只需要在博客的git主目录执行

`git submodule update --init --recursive`

这个时候主题就会直接下载到对应的文件夹

# 恢复

这个就简单了 刚才备份的主题配置文件覆盖回去就行了  
好了这样就设置完了

# 命令

下次更新主题文件就直接执行

`git submodule update`

即可

# 更改过主题源代码

上面的看完再看这个，这个就更简单了

# fork主题源代码

找到你喜欢的主题，点击Github的fork，然后就会在你自己的代码库出现一份主题的代码

# 建立本地子模块

跟上面一样的步骤建立  
只不过在添加子模块的时候把命令

`git submodule add <主题的git地址> themes/<主题名字>`

这里的主题git地址换成你自己库的地址

`git submodule add git@github.com:luodaoyi/hexo-theme-next.git themes/next`

后面的设置跟前面一模一样

# 提交自己的主题更改

按照没有修改过主题的步骤弄完 恢复好了主题设置检查没啥问题之后  
然后进入主题代码的目录

`cd themes/主题名字`

提交主题的更改

    git add .
    git commit -m "剥离主题"
    git push -u origin master

然后在自己的分支上面跟随原主题作者的更新 处理合并 生成的时候直接pull到本地就行

# 为啥要这样做

为啥要这样做 多费劲

这样做的有点有几个

  1. 首先主题设置跟站点设置分离，主题本身就是模块化的为啥非要搞到一起
  2. 以后可以随便换主题玩更改站点配置里面的主题名字即可
  3. 可维护性很好
  4. 方便换电脑

# 多主题切换

按照上的做法可以设置很多套主题  
一套主题对应一套主题配置 可以备份到主题文件里面  
随时切换主题  
切换主题的时候只需要更改站点配置里面对应的主题名字就行了

# 换电脑了

这个更简单 换了新电脑 配置好git环境和 Node.js 环境  
这个时候只需要clone一分自己的源代码到本地  
在本地执行

    npm install -g hexo-cli
    npm install
    git submodule update --init --recursive

好了搞定了

 [1]: https://github.com/iissnan/hexo-theme-next/issues/456#issuecomment-152736486
 [2]: https://git-scm.com/book/zh/v1/Git-%E5%B7%A5%E5%85%B7-%E5%AD%90%E6%A8%A1%E5%9D%97