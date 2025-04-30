---
title: "Cpp1 封装和this指针"
categories: [ "CPP" ]
tags: [ "C","vc6","C语言","cpp" ]
draft: false
slug: "Cpp1 封装和this指针-cpp1封装和this指针"
date: "2018-01-21 15:00:00"
---



## 封装

### C语言和C++语言的区别

C++是对C的补充扩展，C原有的语法C++都支持，并在此基础上扩展了一些新的语法：  
继承、封装、多态、模板等等

### 结构体可以作为参数传递吗

    struct Student
    {
        int a;
        int b;
        int c;
        int d;
    }
    //分析这个函数是如何传递参数的
    int Plus(student s)
    {
        return s.a+s.b+s.c+s.d;
    }
    23:       Student s = {1,2,3,4};
    00401078   mov         dword ptr [ebp-10h],1
    0040107F   mov         dword ptr [ebp-0Ch],2
    00401086   mov         dword ptr [ebp-8],3
    0040108D   mov         dword ptr [ebp-4],4
    24:       Plus(s);
    00401094   sub         esp,10h
    00401097   mov         eax,esp
    00401099   mov         ecx,dword ptr [ebp-10h]
    0040109C   mov         dword ptr [eax],ecx
    0040109E   mov         edx,dword ptr [ebp-0Ch]
    004010A1   mov         dword ptr [eax+4],edx
    004010A4   mov         ecx,dword ptr [ebp-8]
    004010A7   mov         dword ptr [eax+8],ecx
    004010AA   mov         edx,dword ptr [ebp-4]
    004010AD   mov         dword ptr [eax+0Ch],edx
    004010B0   call        @ILT+5(Plus) (0040100a)
    004010B5   add         esp,10h
    16:   int Plus(Student s)
    17:   {
    00401020   push        ebp
    00401021   mov         ebp,esp
    00401023   sub         esp,40h
    00401026   push        ebx
    00401027   push        esi
    00401028   push        edi
    00401029   lea         edi,[ebp-40h]
    0040102C   mov         ecx,10h
    00401031   mov         eax,0CCCCCCCCh
    00401036   rep stos    dword ptr [edi]
    18:       return s.a+s.b+s.c+s.d;
    00401038   mov         eax,dword ptr [ebp+8]
    0040103B   add         eax,dword ptr [ebp+0Ch]
    0040103E   add         eax,dword ptr [ebp+10h]
    00401041   add         eax,dword ptr [ebp+14h]
    19:   }
    //经过观察我们可以发现，结构体参数是通过复制结构体传递参数的

### 将函数写到结构体里面，观察反汇编

    
    struct Student
    {
        int a;
        int b;
        int c;
        int d;
        int Plus()
        {
            return a+b+c+d;
        }
    };
    int main()
    {
        Student s = {1,2,3,4};
        s.Plus();
        return 0;
    }
    14:       int Plus()
    15:       {
    00401060   push        ebp
    00401061   mov         ebp,esp
    00401063   sub         esp,44h
    00401066   push        ebx
    00401067   push        esi
    00401068   push        edi
    00401069   push        ecx
    0040106A   lea         edi,[ebp-44h]
    0040106D   mov         ecx,11h
    00401072   mov         eax,0CCCCCCCCh
    00401077   rep stos    dword ptr [edi]
    00401079   pop         ecx
    0040107A   mov         dword ptr [ebp-4],ecx
    16:           return a+b+c+d;
    0040107D   mov         eax,dword ptr [ebp-4]
    00401080   mov         eax,dword ptr [eax]
    00401082   mov         ecx,dword ptr [ebp-4]
    00401085   add         eax,dword ptr [ecx+4]
    00401088   mov         edx,dword ptr [ebp-4]
    0040108B   add         eax,dword ptr [edx+8]
    0040108E   mov         ecx,dword ptr [ebp-4]
    00401091   add         eax,dword ptr [ecx+0Ch]
    17:       }
    22:       Student s = {1,2,3,4};
    0040D4F8   mov         dword ptr [ebp-10h],1
    0040D4FF   mov         dword ptr [ebp-0Ch],2
    0040D506   mov         dword ptr [ebp-8],3
    0040D50D   mov         dword ptr [ebp-4],4
    23:       s.Plus();
    0040D514   lea         ecx,[ebp-10h]
    0040D517   call        @ILT+10(Student::Plus) (0040100f)
    24:       return 0;
    0040D51C   xor         eax,eax
    //我们可以发现此时结构体是通过指针传参数。
    //跟使用定义为指针的外部方法一样的调用方式和处理方式

### 观察结构体的大小:

    struct Student
    {
        int a;
        int b;
        int c;
        int d;
        int Plus()
        {
            return a+b+c+d;
        }
    };
    int main()
    {
        Student s = {1,2,3,4};
        s.Plus();
        return 0;
    }
    //对比
    struct Student
    {
        int a;
        int b;
        int c;
        int d;
    };
        int Plus(Student* s)
        {
            return s=>a+s=>b+s->c+s->d;
        }
    int main()
    {
        Student s = {1,2,3,4};
        Plus(&s);
        return 0;
    }
    //我们发现上述两种定义方式基本一样

结论：

    在结构体内定义函数，函数其实并不属于这个结构体，这样做仅仅是为了使用方便。
    将函数定义写入到结构体内部，也就是我们所说的封装
    

### 封装总结

  1. 什么是发封装：将函数定义到结构体内部，就是封装
  2. 什么是类：带有函数的结构体，称为类
  3. 什么是成员函数：结构体里面的函数，称为成员函数

## this指针

### 什么是this指针

    struct Student
    {
        int a;
        int b;
        int c;
        int d;
        int Plus()
        {
            return a+b+c+d;
        }
    }

总结:

  1. this指针是编译器默认传入的，通常都会使用`ecx`进行参数的传递。
  2. 你用或者不用，他都在那。

### this指针的使用

    struct Student
    {
        int a;
        int b;
        void Init(int a,int b)
        {
            this->a=a;
            this->b=b;
        }
        void Print()
        {
            printf("%d %d",a,b);
        }
    }

总结:

  1. this指针不能做 ++ &#8212; 等运算，不能重新被赋值。
  2. this指针不占用结构体的宽度 。

## 总结

  1. this指针是编译器默认传入的，通常都会使用ecx进行参数的传递。
  2. 成员函数都有this指针，无论是否使用。
  3. this指针不能做++ &#8211;等运算，不能重新被赋值。
  4. this指针不占用结构体的宽度。