---
title: "简单的GDI操作"
categories: [ "C-lang","CPP","win32" ]
tags: [ "win32" ]
draft: false
slug: "简单的GDI操作-简单的gdi操作"
date: "2018-05-29 03:01:12"
---



# 简单的GDI操作

![][1] 

## 窗口程序的本质 :GUI GDI

GDI: Graphics Device Interface,图形设备接口，这是Windows提供的一组用于绘制图像的API  
GUI: Graphical User Interface,图形用户界面，是指用户操作软件的界面方式，以区别于字符方式

说白了 GDI是一套实打实的接口，真实存在 GUI只是一个概念

## GDI 图像设备接口(Graphics Device Interface)

  1. 设备对象(HWND)
  2. DC(设备上下文，Device Contexts)
  3. 图形对象

| 图形对象        | 作用                        |
| ----------- | ------------------------- |
| 画笔(Pen)     | 影响线条，包括颜色、粗细、虚实、箭头形状等     |
| 画刷(Brushes) | 影响对形状、区域等操作，如使用的颜色、是否有阴影等 |
| 字体(Fonts)   | 影响文字输出的字体                 |
| 位图(Bitmaps) | 影响位图创建、位图操作和保存等。          |

## 相关API

  * 上下文相关:
    
        <code>GetDC       =>  获取上下文
        ReleaseDC   =>  释放上下文
        </code>

  * 线条相关:
    
        <code>MoveToEx/LineTo => 绘制直线
        SetPixel/Getpixel
        </code>

  * 绘制封闭图形
    
        <code>Rectangle   => 绘制矩形
        Ellipse     => 绘制圆形
        RoundRect   => 绘制圆角矩形
        </code>

## demo

<https://github.com/luodaoyi/cpp_code/tree/master/MemoryInjectTool/GDI>

![][2]

 [1]: /uploads/oss/2018-05-29-15275299317864.jpg ""
 [2]: /uploads/oss/2018-05-29-15275339292105.jpg ""