---
title: "利用coding.和daocloud打造全自动发布的hexo博客"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "利用coding和daocloud打造全自动发布的hexo博客-利用coding和daocloud打造全自动发布的hexo博客"
date: "2017-03-12 06:34:18"
---



# 使用Github托管hexo静态博客的优缺点

Hexo 是一个快速、简洁且高效的博客框架。Hexo 使用 [Markdown][1]（或其他渲染引擎）解析文章，在几秒内，即可利用靓丽的主题生成静态网页。

也就是说你用WP做博客已经OUT了，现在流行纯静态博客

静态博客的优点：

  1. 纯静态html 浏览速度极快
  2. 托管到Github pages 不需要主机费用或者是空间费用
  3. 如果域名没有备案，那么默认就是用的Github的cdn 国内访问速度很快，如果备案了可以使用[cloudxns][2]等dns服务让国外国内分开解析，国内使用各种免费cdn，国外使用Github默认CDN

使用github pages 的缺点:

  1. 国内访问的可用性。

> 感谢伟大的gfw-指不定哪天Github就不能访问了

  1. github屏蔽了百度的蜘蛛。

> 百度的蜘蛛太勤奋了，效率也太低了，以至于github官方屏蔽了百度蜘蛛。

  1. 国内访问的速度。

> 这个说实话不算缺点，这个在以前是缺点，后来guthub优化了CDN，现在国内访问默认指向澳大利亚 的cdn接点，如果你以前的主机在国内，你可能不满意现在的速度。不过既然你以前主机在国内，那为何不使用CDN呢？

这些天就以上的问题，做了很多尝试.现在说一说我最终的方案：

  1. 使用[**coding.net**][3]托管hexo博客站点源代码

> 其中主题和站点源代码分开coding.net使用私有项目防止文章源代码和ssh私钥泄露，主题仍然托管在github，以后方便更新修改

  1. 使用[**DaoCloud**][4]的**持续集成**，自动生成静态html发布到github pages而且使用他的自动**镜像构建**生成博客静态页面的可部署Docker镜像这个镜像用来给百度抓取使用。

> 这么做的好处是本地只需要剩下hexo的**scaffolds** **source** 这两个文件夹以后不同电脑间写博客也变得无比的方便

下面详细介绍下整体的实现步骤

# 第一步：使用[coding.net][3]托管博客源代码

## 首先注册[coding.net][3]并新建私有项目如下图

创建完毕之后点击左下角代码页面 查看当前代码的远程仓库地址

## 更改当前git远程仓库到coding.net

在当前站点文件夹使用GitShell执行

    git remote add origin git@git.coding.net:luodaoyi/blog-test.git
    #这里的git地址替换为你自己coding项目的地址

如果遇到错误

> fatal: remote origin already exists.

就先删除现有的远程仓库

    git remote rm origin

再添加coding的远程仓库

    git remote add origin git@git.coding.net:luodaoyi/blog-test.git 

## 分离博客主题和站点文件

> 当然你也可以不这么做，直接提交git就行。但是这样做的好处就是站点源文件和主题分离，精简文件，方便不同电脑间的编辑，你可以在github上面fork一份原来主题作者的主题代码，修改下自己的主题配置即可。记录下git地址，持续集成的时候会用到

编辑站点主目录下的**.gitignore**文件，  
添加**themes/** 。如图

## 提交git到远程仓库

首次更改后先提交到仓库主要测试远程仓库是否配置正确，主题是否分离

    git add .
    git commit -m "第一次提交"
    git push origin master

# 第二步：设置[DaoCloud][4]持续集成自动提交博客到Github Pages

在站点根目录新建**daocloud.yml**文件  
输入代码：

    image: daocloud/ci-node:0.12
    before_script:
        - npm install hexo-cli -g --registry=https://registry.npm.taobao.org
        #  --registry=http://registry.npm.taobao.org 使用淘宝的npm源安装 更快捷
        - npm install --registry=https://registry.npm.taobao.org
        - git clone https://github.com/luodaoyi/hexo-theme-next.git themes/next
        # 克隆主题到主题目录 这里的主题Git地址和目录替换成你自己的主题地址和目录
        - mkdir ~/.ssh
        # 新建私钥文件夹
        - mv .daocloud/id_rsa ~/.ssh/id_rsa
        # 移动私钥到私钥文件夹
        - mv .daocloud/ssh_config ~/.ssh/config
        # 移动ssh配置文件
        - chmod 600 ~/.ssh/id_rsa
        - chmod 600 ~/.ssh/config
        # 赋予可读权限
        - eval $(ssh-agent)
        # 启用ssh-agent进程
        - ssh-add ~/.ssh/id_rsa
        # 添加密约
        - rm -rf .daocloud
        # 删除项目里面的私钥存放目录
        - git config --global user.name "luodoayi"
        - git config --global user.email luodaoyi@gmail.com
        # 配置git
    script:
        - hexo g
        # 生成html
        - hexo d
        # 发布html代码，根据你hexo的设置可以发布到多个平台
        - rm -rf ~/.ssh/
        #删除私钥文件夹

有一点需要注意的是，必须是标准yaml格式，也就是说前面的空格不能是tab **必须是空格**

看到这里你应该会发现了，多了个**.daocloud**文件夹，没错这是我用来存放私钥的文件夹，你也可以自己命名，前提把私钥文件放进去就行了，这样做的目的就是让daocloud的持续集成有push到github pages的能力，你可以新建一组密钥吧公钥绑定到github pages项目的**Deploy Keys**设置里面，这样一来这组私钥也就只有push 网页的权利

> 安全问题，说实话吧私钥放到这里面听不安全的，但是这个私钥对应的公钥，只绑定了github的一个Deploy Keys 也就是说它这把私钥只有发布这个项目的权利

设置好**daocloud.yml**文件和私钥文件夹之后，我们的可持续继承提交就设置完了，接下来干什么呢？对！就是解决百度蜘蛛的问题，我们不需要CDN 也不需要gitcafe，只需要用daocloud的自动**镜像构建**构建一个集成了自己的html页面的Docker并且让daocloud自动部署即可！

# 第三部：设置[DaoCloud][4]构建docker解决百度蜘蛛的问题

> 如果你在hexo中设置同时发布到了gitcafe，那下面就不用看了

在站点根目录新建**Dockerfile**文件设置daocloud自动构建镜像配置  
代码如下

    FROM luodaoyi/docker-library-nginx-git
    MAINTAINER luodaoyi
    RUN mkdir html && cd html
    RUN git clone https://github.com/luodaoyi/luodaoyi.github.io.git blog
    RUN cp -rf blog/* /usr/share/nginx/html
    RUN rm -rf blog
    RUN sed -i "s|#gzip  on;|gzip  on; etag  off; server_tokens off; gzip_types *;|" /etc/nginx/nginx.conf

这里直接使用了我做的Docker镜像，集成了git了nginx 省得每次update半天,速度快了四倍以上  
其中

    RUN git clone https://github.com/luodaoyi/luodaoyi.github.io.git blog

这里是我的github page的地址 你替换成你的即可，完事他会自动clone对应的项目，并且移动到nginx的html目录，简单吧

好到这里我们的本地配置已经完成了 站点目录下的文件应该是这样的

提交以下我们的更改

    git add . && git commit -m "最后设置" && git push origin master 

接下来开始使用daocloud

# 第四步：使用daocloud进行全自动化写博客

首先老样子注册号daocloud账号  
传送门 [DaoCloud][4]

新建一个项目，设置代码源为刚才提交的coding项目

因为我们已经在上面的步骤设置好了自动构建所需要的Dockerfile文件，所以会触发自动构建，只不过这里的自动构建里面的html代码仍然是你目前在github pages中托管的html代码。  
继续设置开启自动构建，关闭构建缓存。

等待构建完成，会一般也就3分钟，会生成一个debian系统镜像，点击“查看镜像” &#8211;>部署&#8211;>基础设置&#8211;>立即部署即可

设置自动部署最新版本 切换到“发布”页面 开启自动发布

daocloud会送一个子域名，可以看到已经跑起来了。你想用自己的域名 下面有选项绑定你的域名指定好canme即可，这里我们只让百度访问这个容易这样就可以抓取了 （这个页面下面可以绑定自有域名daocloud会给你一个cname地址）

以后每次最新的文章push到[coding.net][3]，[DaoCloud][4]会自动克隆coding上的代码，首先进行持续集成，把代码结合hexo生成静态html页面并根据你的hexo设置发布到github pages等不同的的地方，当持续集成成功之后，将触发自动构建，会执行Dockfile里面的构建代码，将刚才发布到github的html静态文件克隆到nginx容器中，发布。  
这就是全部的流程

好了全部设置已经完成了。Push一片新文章看看？接下来需要设置DNS，而且如果你看不懂这么做到底是怎么回事，请看下面的总结

# 总结：dns设置和总流程的说明

## dns设置

先说说DNS设置，经过上面的流程，我们最少有了两个html托管地址：github page和Docker应用  
我们只需要在DNS设置中吧来自于百度的DNS设置成docker应用的dns即可

这样一来，除了就实现了文章的自动发布和解决了百度的抓取问题。  
如果你的域名备案了，可以再加上七牛的DNS，让国内使用七牛DNS，国外使用github 百度使用Docker的应用全方位提高

> [使用七牛FUSION融合CDN加速急速网站][5]

## 发生了什么？

很多人到这里已经晕了，这里我详细解释一下当你编辑好文章PUSH代码到coding以后所发生的一系列事件

  1. Push文章到coding.net
  2. Daocloud得知你有了新的push之后，自动触发持续集成

>   * 在一个Docker中clone你coding中的的源代码
>   * 安装hexo,安装依赖（就是你站点源码目录下`package.json`文件中的包）
>   * 设置git的私钥，设置git全局信息（邮箱，名字等）
>   * 执行`hexo g` 生成html静态页面
>   * 执行`hexo d` 使用hexo的发布功能，发布到你设置好的地方，github pages等

  1. 持续集成成功执行以后触发自动构建功能

>   * 在一个Docker中执行Dockerfile中的shell命令
>   * 首先克隆上一部发布到github pages 中的静态页面代码（因为我们上一部已经生成了，这里就不再生成，直接从github上面克隆即可）
>   * 把html静态页面代码移动到nginx的`/usr/share/nginx/html`目录
>   * 打包镜像发送给DaoCloud部署

  1. 自动构建成功后DaoCloud会把最新打包的Docker镜像重新更新部署，这样刚才创建的代码就用上了最新的html界面

至此全自动构建博客打造完毕  
有疑问请在下面留言哦

**转载请注明大官人博客并注明来源地址**

更新记录：  
2015.11.4 首发

 [1]: https://daringfireball.net/projects/markdown/
 [2]: https://www.cloudxns.net
 [3]: https://coding.net/register?key=34407f8c-b088-4da6-8082-3cafc1bd1570
 [4]: https://www.daocloud.io/
 [5]: http://luodaoyi.com/2015/11/01/qiniucdn/