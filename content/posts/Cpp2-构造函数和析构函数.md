---
title: "Cpp2 构造函数和析构函数"
categories: [ "CPP" ]
tags: [ "C","vc6","cpp" ]
draft: false
slug: "Cpp2 构造函数和析构函数-cpp2构造函数和析构函数"
date: "2018-01-28 05:53:00"
---



## 什么是构造函数

    #include "stdafx.h"
    #include
    struct Sclass {
        int a;
        int b;
        int c;
        int d;
        Sclass()//构造函数
        {
            printf("观察这个函数 \n");
        }
        Sclass(int a,int b,int c,int d)//构造函数
        {
            this->a=a;
            this->b=b;
            this->c=c;
            this->d=d;
            printf("观察这个函数 2\n");
        }
        int Plus()
        {
            return a+b+c+d;
        }
    };
    int main(int argc, char* argv[])
    {
        Sclass s;
        Sclass s2(1,2,3,4);
        return 0;
    }
    //反汇编:
    Sclass s;
    0040D408   lea         ecx,[ebp-10h]
    0040D40B   call        @ILT+5(Sclass::Sclass) (0040100a)
    Sclass s2(1,2,3,4);
    0040D770   push        4
    0040D772   push        3
    0040D774   push        2
    0040D776   push        1
    0040D778   lea         ecx,[ebp-20h]
    0040D77B   call        @ILT+10(Sclass::Sclass) (0040100f)
    //观察发现，分配一个对象，构造函数 方法直接就会被调用
    

总结特点:

  1. 与类名同名/没有返回值
  2. 创建对象的时候执行/主要用于初始化
  3. 可以有多个(最好有一个无参的),称为重载，其他函数也可以重载
  4. 编译器不要求必须提供

## 什么是析构函数

    struct Person {
        int age;
        int level;
        Person()
        {
            printf("无参构造函数执行了。。\n");
        }
        Person(int age,int level)
        {
            printf("有参构造函数执行了 ..\n");
            this->age=age;
            this->level=level;
        }
        ~Person()
        {
            printf("析构函数执行了！！\n");
        }
        void Print()
        {
            printf("%d - %d \n",age,level);
        }
    };
    int main(int argc, char* argv[])
    {
        Person p(1,2);
        p.Print();
        return 0;
    }
    //反汇编
    0040105D   push        2
    0040105F   push        1
    00401061   lea         ecx,[ebp-14h]
    00401064   call        @ILT+0(Person::Person) (00401005)
    00401069   mov         dword ptr [ebp-4],0
    00401070   lea         ecx,[ebp-14h]
    00401073   call        @ILT+10(Person::Print) (0040100f)
    00401078   mov         dword ptr [ebp-18h],0
    0040107F   mov         dword ptr [ebp-4],0FFFFFFFFh
    00401086   lea         ecx,[ebp-14h]
    00401089   call        @ILT+5(Person::~Person) (0040100a)
    0040108E   mov         eax,dword ptr [ebp-18h]
    00401091   mov         ecx,dword ptr [ebp-0Ch]
    00401094   mov         dword ptr fs:[0],ecx
    //可以看得出来 当当前函数执行完毕后，会调用析构函数

析构函数总结:

  1. 只能有一个析构函数，不能重载
  2. 不能带任何参数
  3. 不能带返回值
  4. 主要用于清理工作
  5. 编译器不要求必须提供

### 析构函数何时执行

  1. 当对象在堆栈中分配 `当对象在堆栈中被清理的时候 就会执行,比如在函数中，那么离开函数就会被清理`
  2. 当对象在全局区分配 `当程序进程退出时会执行`

### 析构函数的作用：主要用于清理工作

    struct Person {
        int age;
        int level;
        char* arr;
        Person()
        {
            printf("无参构造函数执行了。。\n");
        }
        Person(int age,int level)
        {
            printf("有参构造函数执行了 ..\n");
            this->age=age;
            this->level=level;
            arr=(char*)malloc(1024); //申请堆内存
        }
        ~Person()
        {
            printf("析构函数执行了！！\n");
            free(arr);//释放堆内存
        }
        void Print()
        {
            printf("%d - %d \n",age,level);
        }
    };