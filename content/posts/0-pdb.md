---
title: "本站上线PDB代理服务"
categories: ["工具" ]
tags: [ "develop" ]
draft: true
slug: "pdb"
date: "2024-07-15 01:25:15"
---


## 为何有这个项目

最近用Visual Studio 写代码经常会遇到pdb文件下载太慢导致调试卡死的问题
研究了半天发现一个项目

[https://github.com/szdyg/pdb_proxy](https://github.com/szdyg/pdb_proxy)

原来可以自己代理

于是乎就搞了一个

```shell
http://msdl.luody.info:88/download/symbols
```
## 使用方法:

手动更改环境`_NT_SYMBOL_PATH`环境变量，使用节点：`http://msdl.luody.info:88/download/symbols`

详细情况看下微软的文档:

[https://learn.microsoft.com/zh-cn/windows-hardware/drivers/debugger/symbol-path](https://learn.microsoft.com/zh-cn/windows-hardware/drivers/debugger/symbol-path)

可以一次性多设置几个, 用`;`分开. 推荐其他的 

```shell
# 国内
http://msdl.blackint3.com:88/download/symbols/
```


```shell
# 香港
http://msdl.szdyg.cn/download/symbols/
```

