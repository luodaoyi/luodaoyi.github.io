---
title: "Fork别人的代码 原作者更新后如何同步"
categories: [ "linux" ]
tags: [ "linux" ]
draft: false
slug: "Fork别人的代码 原作者更新后如何同步-fork别人的代码原作者更新后如何同步"
date: "2017-03-12 06:34:32"
---



我的博客主题是直接fork原作者的，所以当原作者更新之后，我要合并冲突，跟随更新  
下面说一下简单的方法，算是自己做个笔记

# 给主题的fork加一个remote

  * 给 fork 配置一个 remote
  * 使用 git remote -v 查看远程状态

    ➜  next git:(master) git remote -v
    origin    git@github.com:luodaoyi/hexo-theme-next.git (fetch)
    origin    git@github.com:luodaoyi/hexo-theme-next.git (push)

  * 把原作者的远程仓库添加到remote

    git remote add upstream https://github.com/iissnan/hexo-theme-next.git

  * 再次查看是否添加成功

    ➜  next git:(master) git remote -v
    origin    git@github.com:luodaoyi/hexo-theme-next.git (fetch)
    origin    git@github.com:luodaoyi/hexo-theme-next.git (push)
    upstream    https://github.com/iissnan/hexo-theme-next.git (fetch)
    upstream    https://github.com/iissnan/hexo-theme-next.git (push)

# 同步Fork

  * 从上游仓库 fetch 分支和提交点，传送到本地，并会被存储在一个本地分支 upstream/master

    ➜  next git:(master) git fetch upstream
    From https://github.com/iissnan/hexo-theme-next
     * [new branch]      dev        -> upstream/dev
     * [new branch]      master     -> upstream/master
     * [new branch]      pisces     -> upstream/pisces

  * 切换到本地主分支(防止出错)

    ➜  next git:(master) git checkout master
    Already on "master"
    Your branch is up-to-date with "origin/master".

  * 把 upstream/master 分支合并到本地 master 上，这样就完成了同步，并且不会丢掉本地修改的内容。

    ➜  next git:(master) git merge upstream/master
    Already up-to-date.

  * 如果没有需要手动合并的冲突就，直接 git push origin master。直接更新到github上面的fork即可，如果出现需要手动合并的冲突，请继续看下面。

# 合并冲突

冲突有很多种，逻辑冲突啦，树冲突啦，内容冲突什么的，咱不管，一般在这里只会出现内容冲突

方法很简单**_直接编辑冲突文件_**

> 冲突产生后，文件系统中冲突了的文件.里面的内容会显示为类似下面这样：

    a123
    <<<<<<< HEAD
    b789
    =======
    b45678910
    >>>>>>> upstream

其中：  
冲突标记**<<<<<<<** （7个<）与**=======**之间的内容是我的修改，  
**=======**与**>>>>>>>**之间的内容是别人的修改。  
此时，还没有任何其它垃圾文件产生。

直接编辑冲突了的文件，把冲突标记删掉，把冲突正确解决。

然后提交更改重新push即可

    git add . && git commit -m "合并冲突" && git push origin master

完