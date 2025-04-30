---
title: "Cpp8 运算符重载和深浅拷贝"
categories: [ "CPP" ]
tags: [ "C","vc6","C语言" ]
draft: false
slug: "Cpp8 运算符重载和深浅拷贝-cpp8运算符重载和深浅拷贝"
date: "2018-02-23 22:25:00"
---



## 深浅拷贝

相同类型间可以直接拷贝

    // _20180212.cpp : Defines the entry point for the console application.
    //
    #include "stdafx.h"
    #include
    #include
    class A
    {
    private:
        int* a;
    public:
        A()
        {
            a = new int[10];
        }
        virtual ~A()
        {
            delete a;
            printf("析构 A \n");
        }
    };
    int main(int argc,char* argv[])
    {
        A a1;
        A a2;
        a1 = a2;
        return 0;
    }
    //反汇编
    27:       A a1;
    0040108D   lea         ecx,[ebp-14h]
    00401090   call        @ILT+15(B::B) (00401014)
    00401095   mov         dword ptr [ebp-4],0
    28:       A a2;
    0040109C   lea         ecx,[ebp-1Ch]
    0040109F   call        @ILT+15(B::B) (00401014)
    004010A4   mov         byte ptr [ebp-4],1
    29:       a1 = a2;
    004010A8   lea         eax,[ebp-1Ch]
    004010AB   push        eax              //a2 作为参数传递
    004010AC   lea         ecx,[ebp-14h]    //a1 作为this指针传递
    004010AF   call        @ILT+45(A::operator=) (00401032)
    30:       return 0;
    A::operator=:
    004012E0   push        ebp
    004012E1   mov         ebp,esp
    004012E3   sub         esp,44h
    004012E6   push        ebx
    004012E7   push        esi
    004012E8   push        edi
    004012E9   push        ecx
    004012EA   lea         edi,[ebp-44h]
    004012ED   mov         ecx,11h
    004012F2   mov         eax,0CCCCCCCCh
    004012F7   rep stos    dword ptr [edi]
    004012F9   pop         ecx
    //eax = a1首地址
    004012FA   mov         dword ptr [ebp-4],ecx
    004012FD   mov         eax,dword ptr [ebp-4]
    //ecx = a2首地址
    00401300   mov         ecx,dword ptr [ebp+8]
    //ecx + 4 这里是 class A中变量a的地址(ecx 对应虚表地址)
    //因为ecx是变量a2 所以这里的edx = a2.a
    00401303   mov         edx,dword ptr [ecx+4]
    //a2.a 赋值给a1.a
    00401306   mov         dword ptr [eax+4],edx
    //返回a1首地址
    00401309   mov         eax,dword ptr [ebp-4]
    0040130C   pop         edi
    0040130D   pop         esi
    0040130E   pop         ebx
    0040130F   mov         esp,ebp
    00401311   pop         ebp
    00401312   ret         4
    

我们发现使用`=`直接赋值对象，编译器自动生成了`operator=` 函数用于处理类型赋值  
我们观察编译器自动生成的函数`operator=`，这里赋值直接略过了虚表(ecx+4)

    // _20180212.cpp : Defines the entry point for the console application.
    //
    #include "stdafx.h"
    #include
    #include
    class A
    {
    private:
        int* a;
    public:
        A()
        {
            a = new int[10];
        }
        virtual ~A()
        {
            delete a;
            printf("析构 A \n");
        }
        int* get_a()
        {
            return a;
        }
    };
    int main(int argc,char* argv[])
    {
        A a1;
        A* a2 = new A;
        a1 = *a2;
        delete a2;
        int* i = a1.get_a();
        for (int j =0;jn.x && this->y>n.y;
        }
    private:
        int x;
        int y;
    };
    int main(int argc, char* argv[])
    {
        Number n1(1,1),n2(2,2);
        bool r = n1.Max(n2);
        return 0;
    }

> bool类型，其实就是一个char true是1 false是0

为了比较 n1和n2的大小。我们定义了一个max函数。此时我们写的时候有没有感觉很繁琐，那么我们能不能像基础类型那样使用 >这样的符号来做运算呢 比如

    boolr = n1 > n2;

答案是可以的！

    // _20180223.cpp : Defines the entry point for the console application.
    //
    #include "stdafx.h"
    class Number
    {
    public:
        Number(int x,int y):x(x),y(y)
        {
        }
        bool operator>(Number& n)
        {
            return    this->x>n.x && this->y>n.y;
        }
    private:
        int x;
        int y;
    };
    int main(int argc, char* argv[])
    {
        Number n1(1,1),n2(2,2);
        bool r = n1 > (n2);
        return 0;
    }

重载 `++  -- + - * / > <` 等等运算符

    class Number
    {
    public:
        Number(int x,int y):x(x),y(y)
        {
        }
        Number operator++();
        Number operator--();
        Number operator+(const Number& p);
        Number operator-(const Number& p);
        Number operator*(const Number& p);
        Number operator/(const Number& p);
        bool operator(const Number& n)
        {
            return    this->x>n.x && this->y>n.y;
        }
    private:
        int x;
        int y;
    };
    int main(int argc, char* argv[])
    {
        Number n1(1,1),n2(2,2);
        bool r = n1 > (n2);
        return 0;
    }