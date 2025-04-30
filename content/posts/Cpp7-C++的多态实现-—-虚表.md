---
title: "Cpp7 C++的多态实现 — 虚表"
categories: [ "CPP" ]
tags: [ "C","vc6","C语言" ]
draft: false
slug: "Cpp7 C++的多态实现 — 虚表-cpp7c的多态实现虚表"
date: "2018-02-16 14:42:00"
---



## 多态的实现原理


```cpp
#include "stdafx.h"
#include
#include
class A
{
public:
    int x;
    virtual void Test()
    {
        printf("A \n");
    }
protected:
private:
};
class B:public A
{
public:
    int x;
    void Test()
    {
        printf("B \n");
    }
protected:
private:
};
void Fun(A* p)
{
    p->Test();
}
int main(int argc, char* argv[])
{
    A a;
    B b;
    Fun(&b);
    return 0;
}
//我们发现在这里 调用的test函数 是b的 因为fun方法传入的对象是b b继承自a 这里体现了多态
//反编译
31:   void Fun(A* p)
32:   {
00401050   push        ebp
00401051   mov         ebp,esp
00401053   sub         esp,40h
00401056   push        ebx
00401057   push        esi
00401058   push        edi
00401059   lea         edi,[ebp-40h]
0040105C   mov         ecx,10h
00401061   mov         eax,0CCCCCCCCh
00401066   rep stos    dword ptr [edi]
33:       p->Test();
00401068   mov         eax,dword ptr [ebp+8]
0040106B   mov         edx,dword ptr [eax]
0040106D   mov         esi,esp
0040106F   mov         ecx,dword ptr [ebp+8]
00401072   call        dword ptr [edx]    //间接调用 + 虚表
00401074   cmp         esi,esp
00401076   call        __chkesp (00401240)
34:   }
@ILT+0(?Fun@@YAXPAVA@@@Z):
00401005   jmp         Fun (00401050)
@ILT+5(??0B@@QAE@XZ):
0040100A   jmp         B::B (00401190)
@ILT+10(??0A@@QAE@XZ):
0040100F   jmp         A::A (00401100)
@ILT+15(?Test@B@@UAEXXZ):
00401014   jmp         B::Test (004011f0)
@ILT+20(?Test@A@@UAEXXZ):
00401019   jmp         A::Test (00401140)
@ILT+25(_main):
0040101E   jmp         main (004010a0)

```


总结：

    1. 当我们在类中定义虚函数时，就会产生虚表
    2. 多态的实现 间接调用+虚表
    

## 虚表

### 观察带有虚函数的对象大小


```cpp
#include "stdafx.h"
#include
#include
class A
{
public:
    int x;
    void Test()
    {
        printf("A \n");
    }
protected:
private:
};
int main(int argc, char* argv[])
{
    A a;
    printf("%d \n",sizeof(a));
    return 0;
}
//结果是4
```



```cpp
#include "stdafx.h"
#include
#include
class A
{
public:
    int x;
    virtual void Test()
    {
        printf("A \n");
    }
protected:
private:
};
int main(int argc, char* argv[])
{
    A a;
    printf("%d \n",sizeof(a));
    return 0;
}
//结果是 8
```



```cpp
#include "stdafx.h"
#include
#include
class A
{
public:
    int x;
    virtual void Test()
    {
        printf("A \n");
    }
    virtual void Test1()
    {
        printf("A \n");
    }
protected:
private:
};
int main(int argc, char* argv[])
{
    A a;
    printf("%d \n",sizeof(a));
    return 0;
}
//结果还是8
```


发现：定义了虚函数 对象大小会多出4个字节，多个虚函数也只有多一个4字节

### 虚表的位置


```cpp
#include "stdafx.h"
#include
#include
class A
{
public:
    int x;
    virtual void Test()
    {
        printf("A \n");
    }
};
class B:public A
{
public:
    virtual void Test()
    {
        printf("B \n");
    }
};
void Fun(A* a)
{
    a->Test();
}
int main(int argc, char* argv[])
{
    A a;
    B b;
    Fun(&a);
    Fun(&b);
    return 0;
}

```


通过vc6的监视器发现a对象的具体结构

![][1] 

发现加了虚函数之后对象前面对了一个值 指向 `0x00422fac`

那么这里的值指向的就是虚表的位置

继续追踪  
调出内存窗口查找此内存

![][2] 

里面的值是 00401028 (小端存储)

vc6中 ctrl +g 跳转到对应反汇编位置

![][3] 

这里指向的正好是A的test 方法  
(此时多了个TEST1 是因为上次编译后的结果没有清理缓存 )

    26:   void Fun(A* a)
    27:   {
    00401050   push        ebp
    00401051   mov         ebp,esp
    00401053   sub         esp,40h
    00401056   push        ebx
    00401057   push        esi
    00401058   push        edi
    00401059   lea         edi,[ebp-40h]
    0040105C   mov         ecx,10h
    00401061   mov         eax,0CCCCCCCCh
    00401066   rep stos    dword ptr [edi]
    28:       a->Test();
    //取参数也就是a对象的指针 到eax
    00401068   mov         eax,dword ptr [ebp+8]
    //读取eax也就是a对象的首地址 也就是虚表的位置
    0040106B   mov         edx,dword ptr [eax]
    0040106D   mov         esi,esp
    //传递this指针，到ecx
    0040106F   mov         ecx,dword ptr [ebp+8]
    //调用虚表中记录的函数位置 这里是第一个就直接是edx
    00401072   call        dword ptr [edx]
    00401074   cmp         esi,esp
    00401076   call        __chkesp (00401240)
    29:   }
    //虚表
    00401023   jmp         A::A (004010d0)
    00401028   jmp         A::Test (00401090)
    0040102D   jmp         A::Test1 (00401110)
    00401032   jmp         B::B (00401170)
    00401037   jmp         Fun (00401050)
    0040103C   jmp         B::Test (004011c0)
    00401041   jmp         A::A (00401200)
    

## 虚表的结构

据观察，虚表中存储的都是函数地址，每个地址占用4个字节，有几个虚函数，则就有几个地址

## 虚表的内容

子类没有重写时的值


```cpp
#include "stdafx.h"
#include
#include
class A
{
public:
    int x;
    virtual void Test()
    {
        printf("A \n");
    }
};
class B:public A
{
public:
};
void Fun(A* a)
{
    a->Test();
}
int main(int argc, char* argv[])
{
    B b;
    Fun(&b);
    return 0;
}
//虚表
00401014   jmp         A::Test (00401140)
```


子类重写时的值


```cpp
#include "stdafx.h"
#include
#include
class A
{
public:
    int x;
    virtual void Test()
    {
        printf("A \n");
    }
};
class B:public A
{
public:
    virtual void Test()
    {
        printf("B \n");
    }
};
void Fun(A* a)
{
    a->Test();
}
int main(int argc, char* argv[])
{
    B b;
    Fun(&b);
    return 0;
}
//虚表
@ILT+15(?Test@B@@UAEXXZ):
00401014   jmp         B::Test (00401150)
@ILT+20(?Test@A@@UAEXXZ):
00401019   jmp         A::Test (004011e0)
```


### 析构函数问题


```cpp
class A
{
private:
    int* a;
public:
    A()
    {
        a = new int[10];
    }
    ~A()
    {
        delete a;
    }
    int* get_a()
    {
        return a;
    }
}
class B:public A
{
private:
    int* b;
public:
    B()
    {
        b = new int[5];
    }
    ~B()
    {
        delete b;
    }
    int* get_arr(int flag)
    {
        if(flag == 1 )
        {
            return b;
        }
        else
        {
            return get_a();
        }
    }
}
int main()
{
    A* p = new B;
    delete p;
    return 0;
}
```


上述代码执行时，如果直接调用 指针类型是父类，那么只会执行父类的析构函数释放掉 `int* a`  
而b类中的`int* b`却不会被释放掉

理论上最好的方式是 逐步往上调用所有的析构函数，这样才可以释放所有使用的内存


```cpp
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
class B:public A
{
private:
    int* b;
public:
    B()
    {
        b = new int[5];
    }
    ~B()
    {
        delete b;
        printf("析构 B \n");
    }
    int* get_arr(int flag)
    {
        if(flag == 1 )
        {
            return b;
        }
        else
        {
            return get_a();
        }
    }
};
int main(int argc,char* argv[])
{
    A* p = new B;
    delete p;
    return 0;
}
```


这里 将父类的析构函数定义为虚函数，那么`delete`的时候 就会调用子类重写父类虚析构函数的析构函数(虽然名字不相同，但是会自动重写_编译器约定)

并且此时析构函数现实从下往上逐步执行

![][4]

 [1]: /uploads/oss/2018-02-16-15187618448566.jpg ""
 [2]: /uploads/oss/2018-02-16-15187623616244.jpg ""
 [3]: /uploads/oss/2018-02-16-15187624295357.jpg ""
 [4]: /uploads/oss/2018-02-16-15187805575998.jpg ""