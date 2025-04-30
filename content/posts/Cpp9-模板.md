---
title: "Cpp9 模板"
categories: [ "CPP" ]
tags: [ "C","cpp" ]
draft: false
slug: "Cpp9 模板-cpp9模板"
date: "2018-03-01 08:27:00"
---



## 模板

下面是一个针对int的冒泡排序

    // _20180301.cpp : Defines the entry point for the console application.
    //
    #include "stdafx.h"
    void Sort(int* arr,int nLength)
    {
        int i,k;
        for (i = 0;ix > base.x && this->y > base.y;
        }
    private:
        int x;
        int y;
    };
    template
    void Sort(T* arr,int nLength)
    {
        int i,k;
        for (i = 0;iy)
                return x;
            else
                return y;
        }
        M min()
        {