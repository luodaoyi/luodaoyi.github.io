---
title: "解决WSL与windows的PATH环境变量冲突问题"
categories: [ "linux","工具" ]
tags: [  ]
draft: false
slug: "解决WSL与windows的PATH环境变量冲突问题-解决wsl与windows的path环境变量冲突问题"
date: "2020-03-21 04:25:15"
---



> 如果在windows和wsl中都安装了python, 那么由于wsl的互交互特性, pienv的运行就会不太正常

以下是禁用互交互的步骤

在`WSL`的终端中输入:


```shell
echo "[interop]\nenabled=false\nappendWindowsPath=false" | sudo tee /etc/wsl.conf
```


在`Powershell`(以管理员身份运行)中输入: (以重启wsl)


```bat
net stop LxssManager
net start LxssManager
```


> 如果已知distro名, 可用`wsl --terminate <distro名>`终止特定的wsl distro

<!--more-->

效果如下:

[![][1]][2]

 [1]: /uploads/2020/03/1584764684-20191128224648498-300x188.jpg
 [2]: https://luodaoyi.com/?attachment_id=2068