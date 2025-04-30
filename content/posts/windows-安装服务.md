---
title: "windows 安装服务"
categories: [ "CSharp" ]
tags: [ "asp.net","csharp","windows" ]
draft: false
slug: "windows 安装服务-windows安装服务"
date: "2017-09-12 06:58:05"
---



## 方法1 :sc

### 安装

```bat
    //bin目录加上 "s" 证明是从windows服务启动该程序
    sc create server_name binpath="bin_path s" displayName="display_name" start=auto
    sc create elasticsearch_index_sync binpath="D:\job\search-job\Search.JobService.exe s" displayName="elasticsearch index sync work" start=auto
```

### 卸载

```bat
    sc delete server_name binpath="bin_path" displayName="display_name"start= auto
    sc delete elasticsearch_index_sync binpath="D:\job\search-job\Search.JobService.exe" displayName="elasticsearch index sync work" start= auto
```

## 方法2:installutil

### 安装

```bat
    %SystemRoot%\Microsoft.NET\Framework\v4.0.30319\installutil.exe D:\job\search-job\Search.JobService.exe
    Net Start SearchJobService
    sc config SearchJobService start= auto
```

第二行为启动服务。  
第三行为设置服务为自动运行。

### 卸载

```bat
    %SystemRoot%\Microsoft.NET\Framework\v4.0.30319\installutil.exe /u D:\job\search-job\Search.JobService.exe
```

## 控制

### 启动

```bat
    net start server_name
    net start elasticsearch_index_sync
```

### 停止

```bat
    net stop server_name
    net stop elasticsearch_index_sync
```