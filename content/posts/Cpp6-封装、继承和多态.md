---
title: "Cpp6 封装、继承和多态"
categories: [ "CPP" ]
tags: [ "C","vc6","C语言" ]
draft: false
slug: "Cpp6 封装、继承和多态-cpp6封装继承和多态"
date: "2018-02-10 07:40:00"
---



## 继承

  1. 子类从父类继承成员变量
  2. 子类从父类继承成员函数

    #include "stdafx.h"
    class Person
    {
    public:
        int Age;
        int Sex;
        void Word()
        {
            printf("Person:Work");
        }
    };
    class Teacher:public Person
    {
    public:
        int Level;
    };
    int main()
    {
        Teacher t;
        t.Age = -1; //合法但是不合理
        t.Sex = 2;
        t.Level = 3;
        return 0;
    }

## 实现数据隐藏

为什么要隐藏数据成员

  1. 与前面比较，赋值的时候 合理不合法，手机的电路板也没有暴露在外面啊
  2. 根本的目的是可控

## 不要造相同的轮子

代码复用的两种体现方式:

  1. 继承
  2. 共用相同的函数

## 函数的重写

成员函数的重写特征:

  1. 不同的范围(分别位于派生类与基类)
  2. 函数名字相同
  3. 参数相同
  4. 基类函数必须有virtual关键字，称为虚函数

## 多态

多态就是可以让父类指针有多种形态。  
C++中式通过虚函数实现的多态性

## 纯虚函数

  1. 虚函数目的是提供一个统一的接口，被继承的子类重载，以多态的形式被调用。
  2. 如果基类中的函数没有任何实现的意义，那么可以定位为纯虚函数。
    
        virtual 返回类型 函数名(参数列表) =0；
        virtual int fuck(int count) =0;

  3. 含有纯虚函数的类被成为抽象类（abstract class），不能创建对象
  4. 虚函数可以被直接使用，也可以被子类(sub class)重载以后以多态的形式调用，而纯虚函数必须在子类（sub class）中实现该函数才可以使用