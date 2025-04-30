---
title: "API与宽字符"
categories: [ "win32" ]
tags: [ "win32" ]
draft: false
slug: "API与宽字符-api与宽字符"
date: "2018-03-29 13:46:00"
---



# API与宽字符

## API（Application Programming Interface,应用程序编程接口）

### Api的定义

api就是一些`预先定义的函数`，目的是提供应用程序与开发人员基于某软件或者硬件的一访问一组例程的能力，而又无需访问源码，或者理解内部工作机制的细节

### WindowsAPI的定义

WindowsAPI是一套用来控制windows的各个木粉的外观和行为的预先定义的WIndows`函数`  
应用程序`接口`

![][1] 

### Api的使用和查询

调用api函数  
msdn-程序员的宝库

## API中的宽字符

比如MessageBox的定义

    #ifdef UNICODE
    #define MessageBox MessageBoxW
    #else
    #define MessageBox MessageBoxA
    #endif  //!UNICODE
    

如果没有`UNICODE`宏 那么就代表 `MessageBox` 就是`MessageBoxA` 单字节  
反之则为 `MessageBoxW` 宽字节

 [1]: /uploads/oss/2018-03-29-15222490920998.jpg ""