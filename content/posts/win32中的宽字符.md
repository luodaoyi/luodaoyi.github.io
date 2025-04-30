---
title: "win32中的宽字符"
categories: [ "win32","逆向" ]
tags: [ "逆向","win32" ]
draft: false
slug: "win32中的宽字符-win32中的宽字符"
date: "2018-03-28 01:55:20"
---



# win32中的宽字符

## 宽字符

| 数据类型                             | 容器、模板 |      |
| -------------------------------- | ----- | ---- |
| ASCII                            | 一个字符  | 一个字节 |
| GB码(扩展了的ASCII)                   | 英文字符  | 一个字节 |
| GB码                              | 中文字符  | 两个字节 |
| UNICODE字符集(unicode编码实际指的是utf-16) | 常用字符  | 两个字节 |

宽字符： `用多个字节来表示的字符称之为宽字符`(只要不是以单字节存储都可称为宽字符)

注：宽字符不等同与`UTF-16`更不等同与`UNICODE`

## wchar_t 宽字符类型

C/C++中对宽字符定义了一个类型 `wchar_t` 用来存储`两字节宽度`的宽字符

常用的字符串操作字符

    strlen()        wcslen()
    strcmp()        wcscmp()
    strcat()        wcscat()
    strcpy()        wcscpy()
    wchar_t arr[] = L"Hello World";
    printf("%d \r\n",wcslen(arr));

> 在同一个项目工程里务必只使用一种编码规则，一面发生管理紊乱

## Windows定义了一系列新的类型

|         | 原生             | win32 |
| ------- | -------------- | ----- |
| typedef | char           | CHAR  |
| typedef | short          | SHORT |
| typedef | int            | INT   |
| typedef | long           | LONG  |
| typedef | unsigned long  | DWORD |
| typedef | int            | BOOL  |
| typedef | unsigned char  | BYTE  |
| typedef | unsigned short | WORD  |
| typedef | float          | FLOAT |

## 不同项目间合作 单字符和宽字符的问题

常规解决方案(不推荐)：

  1. 事先约定使用同一种编码规范
  2. 在接口处通过某些函数完成两种编码的转换
    
        MultiByteToWideChar()
        WideCharToMultiByte()

微软爸爸的解决方案:

    TCHAR 类型

VC6中 ：定义

    #ifdef UNICODE
        typedef wchar_t TCHAR;
    #else
        typedef unsigned char TCHAR;

使用

    TCHAR arr[] = TEXT"Hello World";