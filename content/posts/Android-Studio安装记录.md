---
title: "Android Studio安装记录"
categories: [ "Android" ]
tags: [ "安卓逆向" ]
draft: false
slug: "Android Studio安装记录-androidstudio安装记录"
date: "2020-04-24 09:37:45"
---



# Android Studio安装记录

> 发现各个大佬都在用AS 我也装一个用一下

## 1. 下载

下载地址:

[https://developer.android.com/studio][1]

![file][2] 

## 2. 直接一路Next

![file][3] 

![file][4] 

![file][5] 

![file][6] 

![file][7] 

等进度条走完就装好了  
![file][8] 

## 3. 配置

![file][9] 

这里要导入配置 毛线的配置 直接点ok

开始配置

![file][10] 

这里选默认,因为简单 自定义又不会

![file][11] 

我喜欢暗黑色

![file][12] 

选择finish 等安装完毕

![file][13] 

这里要等一会 看网络情况  
![file][14] 

## 4. 测试项目

新建一个项目 选Basic Activity

![file][15] 

选个5.0以上的,语言选java

![file][16] 

此时发现，新建项目后运行调试这一排按钮都是灰色，状态栏显示有2个作业一直在执行。  
![file][17] 

原因是因为Android 的 gradle 在构建第一次项目时，需要从外网下载很多依赖的包，如果网络不好可能需要很久

![file][18] 

这里我们使用一个，maven的国内镜像即可 这里根据NCK大佬的博客 用aliyun的  
<https://developer.aliyun.com/mirror/>

![file][19] 

进入Maven镜像，找到gradle选项，复制


```shell
maven { url "https://maven.aliyun.com/repository/public/" }
```


![file][20] 

回到Android Studio界面，找到build.gradle  
找不到的话 as项目中选择Project

![file][21]  
将repositories里面的 google() 和jcenter()替换成下面两句：


```shell
maven { url "https://maven.aliyun.com/repository/google/" }
maven { url "https://maven.aliyun.com/repository/jcenter/" }
```


![file][22] 

之后关闭项目  
重新打开  
![file][23] 

![file][24] 

此时刚才我们的设置就已经生效了，此时下载速度明显快了很多，等gradle构建完成就可以了

![file][25] 

可以看到 两分多钟搞定 

现在用雷电试一下

![file][26]

 [1]: https://developer.android.com/studio "https://developer.android.com/studio"
 [2]: /uploads/2020/04/image-1587719764838.png
 [3]: /uploads/2020/04/image-1587719779809.png
 [4]: /uploads/2020/04/image-1587719787503.png
 [5]: /uploads/2020/04/image-1587719796876.png
 [6]: /uploads/2020/04/image-1587719804463.png
 [7]: /uploads/2020/04/image-1587719813602.png
 [8]: /uploads/2020/04/image-1587719841347.png
 [9]: /uploads/2020/04/image-1587719866167.png
 [10]: /uploads/2020/04/image-1587719907308.png
 [11]: /uploads/2020/04/image-1587719919751.png
 [12]: /uploads/2020/04/image-1587719940647.png
 [13]: /uploads/2020/04/image-1587719975266.png
 [14]: /uploads/2020/04/image-1587719984999.png
 [15]: /uploads/2020/04/image-1587720127954.png
 [16]: /uploads/2020/04/image-1587720250493.png
 [17]: /uploads/2020/04/image-1587720308988.png
 [18]: /uploads/2020/04/image-1587720352137.png
 [19]: /uploads/2020/04/image-1587720469883.png
 [20]: /uploads/2020/04/image-1587720490800.png
 [21]: /uploads/2020/04/image-1587720652516.png
 [22]: /uploads/2020/04/image-1587720717217.png
 [23]: /uploads/2020/04/image-1587720760863.png
 [24]: /uploads/2020/04/image-1587720776050.png
 [25]: /uploads/2020/04/image-1587720971224.png
 [26]: /uploads/2020/04/image-1587721045950.png