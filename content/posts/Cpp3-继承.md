---
title: "Cpp3 继承"
categories: [ "CPP" ]
tags: [ "C","vc6","cpp" ]
draft: false
slug: "Cpp3 继承-cpp3继承"
date: "2018-01-28 06:53:00"
---



## 什么是继承

    struct Person 
    { 
      int age; 
      int sex; 
    };
    struct Teacher 
    { 
      int age; 
      int sex; 
      int level; 
      int classId; 
    };
    struct Teacher:Person 
    { 
      int level; 
      int classId; 
    };

总结：

1、什么是继承？  
继承就是数据的复制  
2、为什么要用继承？  
减少重复代码的编写  
3、Person 称为父类或者基类

4、Teacher称为子类或者派生类

## 继承不仅仅局限于父类

    struct X 
    { 
      int a;
      int b;
    }; 
    struct Y:X 
    { 
      int c;
      int d;
    }; 
    struct Z:Y      //Z的成员只继承c d吗？
    { 
      int e;
      int f;
    };  

内存布局

![][1] 

## 多重继承

    struct X 
    { 
      int a; 
      int b; 
    }; 
    struct Y 
    { 
      int c; 
      int d; 
    }; 
    struct Z:X,Y 
    { 
      int e; 
      int f; 
    };

内存布局：

![][2] 

总结：  
多重继承增加了程序的复杂度，不建议使用。  
多重继承的顺序会影响内存布局 比如继承 `x,y` 和继承`y,x`;z 结构体上面的内存布局是相反的

 [1]: /uploads/oss/2018-01-29-15172331140898.jpg ""
 [2]: /uploads/oss/2018-01-29-15172331512052.jpg ""