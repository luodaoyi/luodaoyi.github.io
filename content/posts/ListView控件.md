---
title: "ListView控件"
categories: [ "CPP","win32" ]
tags: [ "win32" ]
draft: false
slug: "ListView控件-listview控件"
date: "2018-04-09 01:06:00"
---



# ListView控件 实现简单进程管理

## 用到的相关api函数

    //获取控件句柄
    HWND GetDlgItem(
            HWND hDlg,//获得控件所处的窗口的句柄
            int nIDDlgItem //控件id
    );
    //初始化列表的列 （listview插入新的一列
    int ListView_InsertColumn(
        HWNDhwnd, //控件的句柄
        int iCol,  //第几列 (索引 index
        const LPLVCOLUMNpcol //结构体指针 （包含新列的结构体
    );
    //插入新的一行条目
    int ListView_InsertItem(
            HWND hwnd,
            const LPLVITEM pitem
    );
    //设置条目的属性
    BOOL ListView_SetItem(
            HWND hwnd,
            const LPLVITEM pitem
    );
    //删除所有项目
    BOOL ListView_DeleteAllItems(
            HWND hwnd
    );
    //标准输出格式化字符串
    swprintf(buffer,L"%s,哈哈",param);
    //清空
    ZeroMemory(buffer);

list属性：

View-展示形式 ： report-报表形式

## 实现一个简易任务管理器

### 0x1 添加listview控件

找到资源视图，双击并打开

![][1] 

打开工具箱，找到ListControl 拖入到dialog窗体中,调整到适当的大小

![][2] 

记录list控件的id

![][3] 

实现基本窗体代码

![][4] 

### 0x2 初始化list控件

获得控件句柄

![][5] 

调用初始化控件函数

![][6] 

初始化控件列

![][7] 

初始化数据

![][8]

 [1]: /uploads/oss/2018-04-09-15232042167418.jpg ""
 [2]: /uploads/oss/2018-04-09-15232043112875.jpg ""
 [3]: /uploads/oss/2018-04-09-15232043334309.jpg ""
 [4]: /uploads/oss/2018-04-09-15232043883604.jpg ""
 [5]: /uploads/oss/2018-04-09-15232047992295.jpg ""
 [6]: /uploads/oss/2018-04-09-15232048397782.jpg ""
 [7]: /uploads/oss/2018-04-09-15232058277589.jpg ""
 [8]: /uploads/oss/2018-04-09-15232071202052.jpg ""