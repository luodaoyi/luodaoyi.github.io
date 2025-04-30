---
title: "asp.net mvc获得请求体所有内容"
categories: [ "CSharp" ]
tags: [ "asp.net","asp.net mvc" ]
draft: false
slug: "aspnet mvc获得请求体所有内容-aspnetmvc获得请求体所有内容"
date: "2017-03-12 06:15:08"
---



代码如下

    Stream req = Request.InputStream;
    req.Seek(0, System.IO.SeekOrigin.Begin);
    string json = new StreamReader(req).ReadToEnd();