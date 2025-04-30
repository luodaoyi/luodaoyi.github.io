---
title: "C语言7 switch语句为什么高效"
categories: [ "C-lang" ]
tags: [ "逆向","汇编","C" ]
draft: false
slug: "C语言7 switch语句为什么高效-c语言7switch语句为什么高效"
date: "2017-12-28 11:26:00"
---



## switch语句的定义

### 语法

    switch(表达式)
    {
        case 常亮表达式1:
            语句;
            break;
        case 常亮表达式:
            语句;
            break;
        case 常亮表达式:
            语句;
            break;
         ......
        default:
            语句;
            break;
    }

### 需要注意的点

  1. 表达式结束不能使浮点数
  2. case后的值不能一样
  3. case后的值必须是常量

  * `break`:
  * `break`非常重要，当执行到一个分支后 如果没有break就会继续向下执行，遇到break才跳出switch语句
  * `default` 语句与位置无关，但是当default写在其他条件的前面时。如果没有`break;`，就会向下继续匹配

### Switch语句与 if..else语句的区别：

  1. switch语句只能进行等值判断，而if..else可以进行区间判断
  2. switch语句的执行效率远远高于if..else 在分支条件比较多的情况下，这种趋势愈发明显

观察switch语句的反汇编，看看switch语句为啥效率高

## 为啥switch比if..else效率高

### 游戏中的switch语句

    switch(x)
    {
       case 1:
           printf("A \n");
           break;
       case 2:
           printf("B \n");
           break;
       case 3:
           printf("C \n");
           break;
       default:
           printf("default \n");
           break;
    }
    

编译后反汇编代码

    11:        switch(x)
    12:    {
    00401038 8B 45 08             mov         eax,dword ptr [ebp+8]
    0040103B 89 45 FC             mov         dword ptr [ebp-4],eax
    0040103E 83 7D FC 01          cmp         dword ptr [ebp-4],1
    00401042 74 0E                je          MyPrint+32h (00401052)
    00401044 83 7D FC 02          cmp         dword ptr [ebp-4],2
    00401048 74 17                je          MyPrint+41h (00401061)
    0040104A 83 7D FC 03          cmp         dword ptr [ebp-4],3
    0040104E 74 20                je          MyPrint+50h (00401070)
    00401050 EB 2D                jmp         MyPrint+5Fh (0040107f)
    13:       case 1:
    14:           printf("A \n");
    00401052 68 30 00 42 00       push        offset string "A \n" (00420030)
    00401057 E8 B4 00 00 00       call        printf (00401110)
    0040105C 83 C4 04             add         esp,4
    15:           break;
    0040105F EB 2B                jmp         MyPrint+6Ch (0040108c)
    16:       case 2:
    17:           printf("B \n");
    00401061 68 2C 00 42 00       push        offset string "B \n" (0042002c)
    00401066 E8 A5 00 00 00       call        printf (00401110)
    0040106B 83 C4 04             add         esp,4
    18:           break;
    0040106E EB 1C                jmp         MyPrint+6Ch (0040108c)
    19:       case 3:
    20:           printf("C \n");
    00401070 68 28 00 42 00       push        offset string "C \n" (00420028)
    00401075 E8 96 00 00 00       call        printf (00401110)
    0040107A 83 C4 04             add         esp,4
    21:           break;
    0040107D EB 0D                jmp         MyPrint+6Ch (0040108c)
    22:       default:
    23:           printf("default \n");
    0040107F 68 1C 00 42 00       push        offset string "default \n" (0042001c)
    00401084 E8 87 00 00 00       call        printf (00401110)
    00401089 83 C4 04             add         esp,4
    24:           break;
    25:    }
    26:   }
    

### 区别

当调教比较少的时候 没啥区别 。但是当条件比较多的时候：

    
    11:        switch(x)
    12:    {
    0040B818 8B 45 08             mov         eax,dword ptr [ebp+8]
    0040B81B 89 45 FC             mov         dword ptr [ebp-4],eax
    0040B81E 8B 4D FC             mov         ecx,dword ptr [ebp-4]
    0040B821 83 E9 01             sub         ecx,1
    0040B824 89 4D FC             mov         dword ptr [ebp-4],ecx
    0040B827 83 7D FC 03          cmp         dword ptr [ebp-4],3
    0040B82B 77 46                ja          $L539+0Fh (0040b873)
    0040B82D 8B 55 FC             mov         edx,dword ptr [ebp-4]
    0040B830 FF 24 95 91 B8 40 00 jmp         dword ptr [edx*4+40B891h]
    13:       case 1:
    14:           printf("A \n");
    0040B837 68 34 0F 42 00       push        offset string "A \n" (00420f34)
    0040B83C E8 CF 58 FF FF       call        printf (00401110)
    0040B841 83 C4 04             add         esp,4
    15:           break;
    0040B844 EB 3A                jmp         $L539+1Ch (0040b880)
    16:       case 2:
    17:           printf("B \n");
    0040B846 68 30 00 42 00       push        offset string "B \n" (00420030)
    0040B84B E8 C0 58 FF FF       call        printf (00401110)
    0040B850 83 C4 04             add         esp,4
    18:           break;
    0040B853 EB 2B                jmp         $L539+1Ch (0040b880)
    19:       case 3:
    20:           printf("C \n");
    0040B855 68 2C 00 42 00       push        offset string "C \n" (0042002c)
    0040B85A E8 B1 58 FF FF       call        printf (00401110)
    0040B85F 83 C4 04             add         esp,4
    21:           break;
    0040B862 EB 1C                jmp         $L539+1Ch (0040b880)
    22:       case 4:
    23:           printf("D \n");
    0040B864 68 28 00 42 00       push        offset string "D \n" (00420028)
    0040B869 E8 A2 58 FF FF       call        printf (00401110)
    0040B86E 83 C4 04             add         esp,4
    24:           break;
    0040B871 EB 0D                jmp         $L539+1Ch (0040b880)
    25:       default:
    26:           printf("default \n");
    0040B873 68 1C 00 42 00       push        offset string "default \n" (0042001c)
    0040B878 E8 93 58 FF FF       call        printf (00401110)
    0040B87D 83 C4 04             add         esp,4
    27:           break;
    28:    }
    29:   }
    

我们发现 生成一张内存表。  
switch通过算法，直接一步算出地址 从表中找到需要跳转的地址

### 大表和小表

当生成的函数跳转地址表 每个成员有4个字节的时候 我们称之为 大表

## 总结：

  1. 即没有大表也没有小表：
    
      * case 项小于等于3项
      * case最大值和最小值差值>=255

  2. 有大表没小表：
    
      * case项大于3项并且大表项空隙小于等于6个

  3. 有大表有小表
    
      * case项大于3项并且大表项空隙大于6个并且case最大最小差值