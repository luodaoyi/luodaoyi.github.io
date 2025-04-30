---
title: "Cpp4 类成员的访问控制"
categories: [ "CPP" ]
tags: [ "C","cpp" ]
draft: false
slug: "Cpp4 类成员的访问控制-cpp4类成员的访问控制"
date: "2018-01-30 14:02:00"
---



## 好的编程习惯 -定义和实现分开

  1. 代码会有更好的可读性
  2. 但不是必须的

在头文件中只留下声明代码

Test.h

    struct sclass
    {
        int x;
        int y;
        int Bigger(int x,int y);
        int Max(int x,int y,int z);
    };

Test.cpp

    int sclass::Bigger(int x,int y)
    {
        if(x>y)
        {
            return x;
        }
        else
        {
            return y;
        }
    }
    int sclass::Max(int x,int y,int z)
    {
        return Bigger(Bigger(x,y),z);
    }

使用:  
main.cpp

    #include "Test.h"
    #include
    #include
    int main(int argc,char* arhv[])
    {
        sclass s;
        return 0;
    }

上面的实现方式没有问题，但是其实我们的`Bigger`函数是为了实现`MAX`函数存在的，换句话说 我们不想让外部用户去调用`Bigger`函数，为了实现这一目的 我们该怎么办呢？C++的语法允许我们控制类成员的访问权限

## public和private的使用

Test.h

    struct sclass
    {
    private:
        int x;
        int y;
        int Big(int x,int y);
    public:
        int Max(int x,int y,int z);
    };

Test.cpp

    int sclass::Big(int x,int y)
    {
        return x>y?x:z;
    }
    int sclass::Max(int x,int y,int z)
    {
        return Big(Big(x,y),z);
    }

  1. 对外提供的函数或者变量，发布成public ，不能随意改动
  2. 可能会变动的函数或者变量，定义成privvate 这样编译器会在使用的时候做检测。
  3. 只有结构体内部的函数才可以访问private的成员
  4. public/private可以修饰函数也可以修饰变量

### private真的不能访问吗？

    struct Test 
    { 
    private: 
      int x; 
    public: 
      int y; 
      void Init(int x,int y) 
      { 
      this->x = x; 
      this->y = y; 
      } 
    }; 
     
    Test t; 
    t.Init(1,2); 
    int* p = (int*)&t; 
    int n = *p;      //这里取到的就是x
    int m = *(p+1);  //这里取到的就是y
    printf("%d %d\n",n,m);

总结：  
private修饰的成员与普通的成员没有区别 只是编译器会检测。  
private修饰的成员只要自己的其他成员才能访问。

## class与struct的区别

    class Base 
    { 
      int x; 
      int y; 
    }; 
     
    int main(int argc, char* argv[]) 
    { 
      Base base; 
     
      base.x = 10; 
      base.y = 20; 
     
      return 0; 
    }

等价于:

    struct Base 
    { 
    private:
      int x; 
      int y; 
    }; 
     
    int main(int argc, char* argv[]) 
    { 
      Base base; 
     
      base.x = 10; 
      base.y = 20; 
     
      return 0; 
    }

class与struct的区别： 

编译器默认class中的成员为private 而struct中的成员为public

## 继承的区别

    class Base 
    { 
    public: 
      int x;
      int y;
    }; 
    class Sub:Base    -----> class Sub:private Base 
    { 
    public: 
      int a;
      int b;
    };
    int main(int argc, char* argv[]) 
    { 
      Sub sub; 
      sub.x = 1;  //无法访问 
      sub.y = 2;  //无法访问 
      sub.a = 3; 
      sub.b = 4; 
      return 0; 
    }  

class默认直接继承 此时子类继承父类的属性默认为private 除非直接声明public

    class Sub:public Base

## private成员是否被继承？

    class Base 
    { 
    public: 
      Base() 
      { 
        x = 11; 
        y = 12; 
      } 
    private: 
      int x; 
      int y; 
    }; 
    class Sub:Base 
    { 
    public: 
      int a; 
      int b; 
    }; 
    int main(int argc, char* argv[]) 
    { 
      Sub sub; 
      sub.a = 1; 
      sub.b = 2; 
     
      int* p = (int*)&sub; 
     
      printf("%d\n",sizeof(sub));  //16字节
      printf("%d\n",*(p+0));  //x =11
      printf("%d\n",*(p+1));  //y =12
      printf("%d\n",*(p+2));  //a =1
      printf("%d\n",*(p+3));  //b =2
     
      return 0; 
    }

总结： 

1、父类中的私有成员是会被继承的  
2、只是编译器不允许直接进行访问